#!/usr/bin/env python3
# Minimal check script for a specific migration file (example: planned workout fields)
import os
import sys
import mysql.connector

TARGET_FILE = os.path.join(os.path.dirname(__file__), 'migrations', 'add_planned_workout_fields.sql')


def get_conn():
    return mysql.connector.connect(
        host=os.getenv("MYSQLHOST"),
        user=os.getenv("MYSQLUSER"),
        password=os.getenv("MYSQLPASSWORD"),
        database=os.getenv("MYSQLDATABASE"),
        port=int(os.getenv("MYSQLPORT", 3306)),
    )


def check_columns():
    try:
        with get_conn() as db:
            cur = db.cursor()
            cur.execute("DESCRIBE app_workouts")
            cols = [r[0] for r in cur.fetchall()]
            required = ['planned_workout_id','is_planned','planned_tss','actual_tss','plan_version','execution_date']
            missing = [c for c in required if c not in cols]
            return missing
    except Exception as e:
        print(f"Error checking columns: {e}")
        return None


def apply_target():
    try:
        with open(TARGET_FILE, 'r', encoding='utf-8') as f:
            sql = f.read()
        with get_conn() as db:
            cur = db.cursor()
            for stmt in [s.strip() for s in sql.split(';') if s.strip()]:
                try:
                    cur.execute(stmt)
                except mysql.connector.Error as e:
                    if 'Duplicate' in str(e) or 'exists' in str(e):
                        continue
                    raise
            db.commit()
        return True
    except Exception as e:
        print(f"Error applying migration: {e}")
        return False


def main():
    missing = check_columns()
    if missing is None:
        print("Cannot verify DB connection.")
        sys.exit(1)
    if missing:
        print("Missing columns:", missing)
        if not apply_target():
            print("Failed to apply migration.")
            sys.exit(1)
        print("Migration applied.")
    else:
        print("All columns present. Nothing to do.")

if __name__ == '__main__':
    main()
