#!/usr/bin/env python3
import os
import hashlib
from datetime import datetime, timezone
import mysql.connector
from mysql.connector import errorcode
from contextlib import contextmanager

# DB connection via env vars
@contextmanager
def get_db():
    connection = None
    try:
        connection = mysql.connector.connect(
            host=os.getenv("MYSQLHOST"),
            user=os.getenv("MYSQLUSER"),
            password=os.getenv("MYSQLPASSWORD"),
            database=os.getenv("MYSQLDATABASE"),
            port=int(os.getenv("MYSQLPORT", 3306)),
        )
        yield connection
    finally:
        if connection is not None and connection.is_connected():
            connection.close()

def _read_sql(file_path: str) -> str:
    # Normalize potential UTF-8 BOM and return text
    with open(file_path, "r", encoding="utf-8") as f:
        return f.read().lstrip("\ufeff")

# Simple splitter by ';' that tolerates newlines/comments

def _split_statements(sql: str):
    # Simple splitter tolerant to -- comments, /* */ blocks and BOM
    parts = []
    buffer = []
    in_block_comment = False
    for raw in sql.splitlines():
        line = raw.lstrip("\ufeff")
        striped = line.strip()
        if in_block_comment:
            if "*/" in line:
                in_block_comment = False
            continue
        if striped.startswith("/*"):
            in_block_comment = not striped.endswith("*/")
            continue
        if striped.startswith("--") or striped == "":
            continue
        buffer.append(line)
        if line.rstrip().endswith(";"):
            parts.append("\n".join(buffer).strip())
            buffer = []
    if buffer:
        tail = "\n".join(buffer).strip()
        if tail:
            parts.append(tail)
    return parts


def _ensure_migrations_table():
    with get_db() as db:
        cur = db.cursor()
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
        db.commit()


def _already_applied(filename: str, checksum: str) -> bool:
    with get_db() as db:
        cur = db.cursor()
        cur.execute(
            "SELECT checksum FROM schema_migrations WHERE filename = %s",
            (filename,),
        )
        row = cur.fetchone()
        if not row:
            return False
        return row[0] == checksum


def _record_applied(filename: str, checksum: str):
    with get_db() as db:
        cur = db.cursor()
        cur.execute(
            "INSERT INTO schema_migrations(filename, checksum, applied_at) VALUES (%s, %s, %s)",
            (filename, checksum, datetime.now(timezone.utc)),
        )
        db.commit()


def _hash(sql: str) -> str:
    return hashlib.sha256(sql.encode("utf-8")).hexdigest()


def collect_migration_files() -> list[str]:
    repo_root = os.path.abspath(os.path.dirname(__file__))
    mig_dir = os.path.join(repo_root, "migrations")
    candidates: list[str] = []
    if os.path.isdir(mig_dir):
        for name in sorted(os.listdir(mig_dir)):
            if name.lower().endswith(".sql"):
                candidates.append(os.path.join(mig_dir, name))
    return candidates


def apply_all():
    _ensure_migrations_table()
    files = collect_migration_files()
    for fp in files:
        try:
            sql = _read_sql(fp)
            checksum = _hash(sql)
            filename = os.path.basename(fp)
            if _already_applied(filename, checksum):
                continue

            statements = _split_statements(sql)
            if not statements:
                _record_applied(filename, checksum)
                continue

            benign_errors = {
                errorcode.ER_TABLE_EXISTS_ERROR,        # 1050
                errorcode.ER_DUP_FIELDNAME,            # 1060
                errorcode.ER_DUP_KEYNAME,              # 1061
                errorcode.ER_CANT_DROP_FIELD_OR_KEY,   # 1091
                errorcode.ER_DUP_ENTRY,                # 1062
                3757,                                  # Functional index error on JSON/BLOB (MySQL 8)
            }

            with get_db() as db:
                cur = db.cursor()
                for stmt in statements:
                    s = stmt.strip()
                    if not s:
                        continue
                    try:
                        cur.execute(s)
                    except mysql.connector.Error as err:
                        msg = str(err).lower()
                        if err.errno in benign_errors or "functional index" in msg:
                            # Log and continue (idempotent or unsupported operation)
                            print(f"  Skipping benign error [{err.errno}] for statement: {s[:120]}...")
                            continue
                        # Re-raise other errors to surface the problem
                        raise
                db.commit()
            _record_applied(filename, checksum)
        except Exception as e:
            print(f"Migration failed for {fp}: {e}")

if __name__ == "__main__":
    apply_all()
