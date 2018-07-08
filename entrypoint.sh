#!/usr/bin/env bash

# Wait for PG to be ready
until PGPASSWORD=postgres psql -h postgres -U postgres -c "select version()" &> /dev/null
do
    echo "waiting for postgres container..."
    sleep 2
done
PGPASSWORD=postgres psql -h postgres -U postgres -c 'CREATE EXTENSION IF NOT EXISTS "pgcrypto"'
PGPASSWORD=postgres psql -h postgres -U postgres -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp"'

echo "$@"
exec "$@"

