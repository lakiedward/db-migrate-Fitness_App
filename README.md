# db-migrate

Standalone repository for database schema and migrations for Fitness App.

Contents
- `migrations/`: ordered `.sql` files applied incrementally
- `migrate_runner.py`: lightweight runner that applies all outstanding migrations
- Optional assets copied from backend: `schema.sql`, `backup.sql`

Run
```bash
python -m pip install -r requirements.txt
# Set env: MYSQLHOST, MYSQLUSER, MYSQLPASSWORD, MYSQLDATABASE, [MYSQLPORT]
python migrate_runner.py
```

How it works
- Keeps a `schema_migrations` table (filename, checksum, applied_at)
- Computes sha256 of each SQL file, applies in lexicographic order
- Skips files already applied with the same checksum

Notes
- Write idempotent SQL where possible (CREATE TABLE IF NOT EXISTS)
- End statements with `;` so splitting works
- Avoid `USE <db>`; connection selects database already

Related services
- Railway service `db-migrate-Fitness_App` should pull from this repo and run `python migrate_runner.py` at start.
- The FastAPI backend does not carry migration files anymore; it only uses DB via connection env vars.
