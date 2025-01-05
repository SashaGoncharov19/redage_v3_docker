#!/bin/bash
set -e

# Wait for MariaDB to start
while ! mariadb -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1;" &>/dev/null; do
    echo "Waiting for MariaDB to start..."
    sleep 2
done

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-"root"}

DBS=("ra3_main" "ra3_mainconfig" "ra3_mainlogs")

# Function to check if database exists
check_database_exists() {
    mariadb -uroot -p"$MYSQL_ROOT_PASSWORD" -e "USE $1;" 2>/dev/null
    return $?
}

# Create databases and user
for DB in "${DBS[@]}"; do
    if ! check_database_exists "$DB"; then
        echo "Creating database $DB..."
        mariadb -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE $DB;"
    else
        echo "Database $DB already exists, skipping creation."
    fi
done

# Import SQL files
for DB in "${DBS[@]}"; do
    SQL_FILE="/docker-entrypoint-initdb.d/${DB}.sql"
    if [ -f "$SQL_FILE" ]; then
        echo "Importing $SQL_FILE into $DB..."
        mariadb -uroot -p"$MYSQL_ROOT_PASSWORD" "$DB" < "$SQL_FILE"
    else
        echo "SQL file $SQL_FILE not found, skipping import."
    fi
done

echo "Database initialization complete."

# Run the default entrypoint for MariaDB
exec docker-entrypoint.sh mysqld
