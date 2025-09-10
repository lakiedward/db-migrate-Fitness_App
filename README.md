# Fitness App – db-migrate (Migrații SQL)

Repo dedicat pentru migrațiile incrementale ale bazei de date. Rulează în afara backendului și este potrivit pentru un serviciu Railway separat (ex. `db-migrate-Fitness_App`).

## Rol în arhitectură
- `BD_Fitness_App` – creează schema inițială (init scripts). Folosit la bootstrap sau local cu Docker.
- `db-migrate` – aplică incremental fișiere `.sql` noi/actualizate, păstrând un istoric în `schema_migrations`.
- `Fitness_app` – consumă DB (nu conține migrații).

## Conținut repo
- `migrations/` – fișiere `.sql` ordonate lexicografic (ex. `000_...`, `001_...`)
- `migrate_runner.py` – aplică toate migrațiile neaplicate încă
- `apply_migration.py` – aplică un singur fișier
- `check_and_apply_migration.py` – exemplu de verificare/auto‑aplicare pentru o migrare specifică
- `requirements.txt` – dependențe minime (`mysql-connector-python`, `python-dotenv`)
- (opțional) `schema.sql`, `backup.sql` – referință/backup

## Cum funcționează runner‑ul
- Tabel `schema_migrations`:
  - `filename` (UNIQUE), `checksum` (sha256), `applied_at`
- La fiecare rulare:
  - Sortează fișierele `.sql`, calculează checksum, compară cu istoricul și aplică doar ce e nou sau schimbat
  - Împarte comenzi după `;` și rulează într‑o tranzacție per fișier

## Convenții pentru migrații
- Prefix numeric pentru ordine: `000_create_users_table.sql`, `010_add_index.sql`
- Fii idempotent: `CREATE TABLE IF NOT EXISTS`, verificări pentru `ADD COLUMN` unde e posibil
- Fără `USE <db>`; conexiunea selectează baza de date
- Termină fiecare statement cu `;`

## Rulare local
```bash
python -m pip install -r requirements.txt
# setează MYSQLHOST, MYSQLUSER, MYSQLPASSWORD, MYSQLDATABASE, [MYSQLPORT]
python migrate_runner.py
```

Rulare fișier unic:
```bash
python apply_migration.py migrations/000_create_users_table.sql
```

## Configurare în Railway
- Creează serviciul `db-migrate-Fitness_App` din acest repo
- Start command: `python migrate_runner.py` (configurat și în `railway.toml`)
- Variabile de mediu necesare: `MYSQLHOST`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLDATABASE`, `MYSQLPORT`
- Setează dependență pe serviciul DB (și pe `BD_Fitness_App` dacă îl folosești la bootstrap)

## Troubleshooting
- „Access denied for user”: verifică credențialele MYSQL_*
- „Unknown column/duplicate column/table”: adaptează migrarea să fie idempotentă sau scrie o migrare de „remediere” ulterioară
- „Lock wait timeout exceeded”: rulează migrarea când nu există trafic intens sau împarte fișierul în pași mai mici

## Repozitoare înrudite
- Backend API: C:\Users\lakie\PycharmProjects\Fitness_app
- Bootstrap DB: C:\Users\lakie\BD_Fitness_App

---

## English Summary

This repository hosts incremental SQL migrations for the Fitness App database. It runs outside the backend and is designed to be deployed as a separate Railway service (e.g., `db-migrate-Fitness_App`).

Contents
- `migrations/` – ordered `.sql` files
- `migrate_runner.py` – applies all outstanding migrations, maintains `schema_migrations`
- `apply_migration.py` – apply a single file
- Optional: `schema.sql`, `backup.sql`

Run
```bash
python -m pip install -r requirements.txt
export MYSQLHOST=... MYSQLUSER=... MYSQLPASSWORD=... MYSQLDATABASE=... MYSQLPORT=3306
python migrate_runner.py
```

Notes
- Keep migrations idempotent and end each statement with `;`
- Avoid `USE <db>`; connection already selects the DB

Related services
- Railway service `db-migrate-Fitness_App` should run `python migrate_runner.py`
- The FastAPI backend no longer carries migrations; it only uses the DB via env vars
