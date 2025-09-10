#!/usr/bin/env python3
"""
Script to run the oauth_states table migration
"""

import mysql.connector
from mysql.connector import Error
import os
from dotenv import load_dotenv

load_dotenv()

def run_migration():
    try:
        # Database connection
        connection = mysql.connector.connect(
            host=os.getenv("DB_HOST", "localhost"),
            user=os.getenv("DB_USER", "root"),
            password=os.getenv("DB_PASSWORD", ""),
            database=os.getenv("DB_NAME", "fitness_app")
        )
        
        if connection.is_connected():
            cursor = connection.cursor()
            
            # Read and execute migration
            with open("app/database/migrations/add_oauth_states_table.sql", "r") as f:
                migration_sql = f.read()
            
            # Split by semicolon and execute each statement
            statements = migration_sql.split(';')
            for statement in statements:
                statement = statement.strip()
                if statement:
                    cursor.execute(statement)
                    print(f"Executed: {statement[:50]}...")
            
            connection.commit()
            print("Migration completed successfully!")
            
    except Error as e:
        print(f"Error: {e}")
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

if __name__ == "__main__":
    run_migration() 