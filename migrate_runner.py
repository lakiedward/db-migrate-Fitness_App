#!/usr/bin/env python3
import os
import hashlib
from datetime import datetime
import mysql.connector
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
    with open(file_path, "r", encoding="utf-8") as f:
        return f.read()

# Simple splitter by ';' that tolerates newlines/comments

def _split_statements(sql: str):
    parts = []
    buffer = []
    for line in sql.splitlines():
        if line.strip().startswith("--"):
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
            (filename, checksum, datetime.utcnow()),
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

            with get_db() as db:
                cur = db.cursor()
                for stmt in statements:
                    s = stmt.strip()
                    if not s:
                        continue
                    cur.execute(s)
                db.commit()
            _record_applied(filename, checksum)
        except Exception as e:
            print(f"Migration failed for {fp}: {e}")

if __name__ == "__main__":
    apply_all()
