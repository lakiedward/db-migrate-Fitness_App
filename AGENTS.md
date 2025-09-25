# AGENTS (Migrații DB – modul db-migrate-Fitness_App)

Acest fișier acoperă runner-ul și scripturile de migrare MySQL. Pentru reguli comune, vedeți `../AGENTS.md` (rădăcina repo-ului).

## Domeniu
- Gestionarea schemelor și migrațiilor MySQL: creare tabele, indecși, coloane, constrângeri, seed-uri.

## Locație și directoare cheie
- Rădăcina modulului: `db-migrate-Fitness_App/`
- Runner: `migrate_runner.py`
- Migrații: `migrations/`
- Inițiale (dacă sunt folosite): `init/`

## Setup și comenzi utile
- Mediu virtual (Win): `python -m venv .venv && .venv\Scripts\activate`
- Mediu virtual (Unix): `python -m venv .venv && source .venv/bin/activate`
- Dependențe: `pip install -r requirements.txt`
- Rulare: `python migrate_runner.py` (necesită variabile de mediu MySQL setate: host, user, password, db)

Recomandări:
- Aplicați migrațiile într-un mediu de test înainte de producție.
- Documentați fiecare migrare (scop, backward-compat) în mesajul PR.

## Semnale de handoff
- Orice modificare de schemă care afectează contractele API → comunicați Backend (`../Fitness_app/`) și Android (`../FitnessApp/`).
- Schimbări sensibile de date (ex. deduplicări, migrare masivă) → anunțați toți consumatorii.

## Resurse
- `README.md`, `requirements.txt`, `railway.toml` (dacă este folosit pentru CI/CD) în acest modul.

