import os
import hashlib
from datetime import datetime
import mysql.connector


def get_db_conn():
    return mysql.connector.connect(
        host=os.getenv("MYSQLHOST"),
        user=os.getenv("MYSQLUSER"),
        password=os.getenv("MYSQLPASSWORD"),
        database=os.getenv("MYSQLDATABASE"),
        port=int(os.getenv("MYSQLPORT", 3306)),
    )


def read_sql(path: str) -> str:
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def split_statements(sql: str):
    parts = []
    buff = []
    for line in sql.splitlines():
        if line.strip().startswith("--"):
            continue
        buff.append(line)
        if line.rstrip().endswith(";"):
            parts.append("\n".join(buff).strip())
            buff = []
    tail = "\n".join(buff).strip()
    if tail:
        parts.append(tail)
    return [p for p in parts if p and p != ";"]


def sha(sql: str) -> str:
    return hashlib.sha256(sql.encode("utf-8")).hexdigest()


def ensure_migrations_table(conn):
    cur = conn.cursor()
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS schema_migrations (
          id INT PRIMARY KEY AUTO_INCREMENT,
          filename VARCHAR(255) NOT NULL UNIQUE,
          checksum VARCHAR(64) NOT NULL,
          applied_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
        """
    )
    conn.commit()
    cur.close()


def already_applied(conn, filename: str, checksum: str) -> bool:
    cur = conn.cursor()
    cur.execute("SELECT checksum FROM schema_migrations WHERE filename = %s", (filename,))
    row = cur.fetchone()
    cur.close()
    return bool(row and row[0] == checksum)


def record_applied(conn, filename: str, checksum: str):
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO schema_migrations(filename, checksum, applied_at) VALUES (%s, %s, %s)",
        (filename, checksum, datetime.utcnow()),
    )
    conn.commit()
    cur.close()


def collect_files() -> list[str]:
    repo = os.getcwd()
    dirs_env = os.getenv("MIGRATIONS_DIRS")
    dirs = (
        [p.strip() for p in dirs_env.split(",") if p.strip()]
        if dirs_env
        else [os.path.join(repo, "init"), os.path.join(repo, "migrations")]
    )
    files: list[str] = []
    for d in dirs:
        if os.path.isdir(d):
            for name in sorted(os.listdir(d)):
                if name.lower().endswith(".sql") and "create_database" not in name.lower():
                    files.append(os.path.join(d, name))
    return files


def apply_all():
    conn = get_db_conn()
    try:
        ensure_migrations_table(conn)
        for fp in collect_files():
            sql = read_sql(fp)
            checksum = sha(sql)
            fname = os.path.basename(fp)
            if already_applied(conn, fname, checksum):
                continue
            try:
                for stmt in split_statements(sql):
                    cur = conn.cursor()
                    try:
                        cur.execute(stmt)
                        # Consume any result set to avoid "commands out of sync"
                        try:
                            if getattr(cur, "with_rows", False):
                                cur.fetchall()
                            # Advance through any additional result sets
                            advance = getattr(cur, "nextset", None)
                            if callable(advance):
                                while True:
                                    more = advance()
                                    if not more:
                                        break
                                    if getattr(cur, "with_rows", False):
                                        cur.fetchall()
                        except Exception:
                            # Swallow fetch/nextset issues; statement already executed
                            pass
                        finally:
                            cur.close()
                        conn.commit()
                    except Exception as ex_stmt:
                        try:
                            cur.close()
                        except Exception:
                            pass
                        conn.rollback()
                        print(f"Failed in {fname} on: {stmt[:120]}... -> {ex_stmt}")
                        raise
                # Mark file applied only if all statements executed
                record_applied(conn, fname, checksum)
                print(f"Applied: {fname}")
            except Exception:
                raise
    finally:
        conn.close()


if __name__ == "__main__":
    apply_all()
