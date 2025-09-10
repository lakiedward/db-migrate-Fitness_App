# DB Migrate (Railway job)

Lightweight migration runner for Fitness App.

## What it does
- Connects to MySQL using env vars: `MYSQLHOST, MYSQLPORT, MYSQLUSER, MYSQLPASSWORD, MYSQLDATABASE`.
- Applies all `.sql` files from `init/` then `migrations/` (alphabetical), skipping `*create_database*.sql`.
- Tracks applied files in `schema_migrations` (filename + checksum). Safe to rerun.

## Run locally
```
python -m venv .venv
. .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
set MYSQLHOST=...
set MYSQLUSER=...
set MYSQLPASSWORD=...
set MYSQLDATABASE=...
python migrate_runner.py
```

## Railway service
- Root Directory: this repo folder (`db-migrate`).
- Build: Nixpacks (Python detected via requirements.txt).
- Start Command: `python -m migrate_runner` (or `python migrate_runner.py`).
- Variables: set `MYSQLHOST=bd_fitness_app.railway.internal`, `MYSQLPORT=3306`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE`.
- Serverless: ON (optional) — job rulează și se oprește.
- Restart policy: On Failure (1-2 retries).

## Notes
- Include aici doar migrări idempotente. Inițializarea completă a bazei (schema) se face de serviciul DB la primul boot (init/ din container MySQL).
- Poți adăuga noi fișiere `.sql` în `migrations/`. Runnerul le va aplica la următorul push.

