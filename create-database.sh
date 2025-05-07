#!/bin/bash
set -e

echo "Creating database: $POSTGRES_DB_DATABASE"
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE "$POSTGRES_DB_DATABASE";
EOSQL
