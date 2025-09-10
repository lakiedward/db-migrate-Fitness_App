#!/usr/bin/env python3
import sys
import os
from contextlib import contextmanager
import mysql.connector

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

def apply_migration(migration_file):
    if not os.path.exists(migration_file):
        print(f"Error: Migration file '{migration_file}' not found.")
        return False
    print(f"Applying migration from '{migration_file}'...")
    with open(migration_file, 'r', encoding='utf-8') as f:
        sql = f.read()
    try:
        with get_db() as db:
            cursor = db.cursor()
            for stmt in [s.strip() for s in sql.split(';') if s.strip()]:
                print(f"Executing: {stmt[:100]}...")
                cursor.execute(stmt)
            db.commit()
            print("Migration applied successfully.")
            return True
    except Exception as e:
        print(f"Error applying migration: {e}")
        return False

def main():
    if len(sys.argv) < 2:
        print("Usage: python apply_migration.py <path_to_sql>")
        sys.exit(1)
    ok = apply_migration(sys.argv[1])
    sys.exit(0 if ok else 1)

if __name__ == "__main__":
    main()
