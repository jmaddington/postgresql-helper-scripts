#!/usr/bin/env bash

# Help message
show_help() {
  echo "Usage: $0 [OPTION]... [DUMP_FILE]"
  echo "Load PostgreSQL database using environment variables and dump file or stdin."
  echo
  echo "Options:"
  echo "  --drop-tables   Drop all tables before loading the dump."
  echo "  --clean         Truncate all tables in the public schema before loading the dump."
  echo "  --help          Display this help and exit."
  echo
  echo "If DUMP_FILE is not provided, the script will read from standard input."
  echo
  exit 0
}

# Check for flags
drop_tables=false
clean=false
dump_file="-"  # Default to stdin if no file is provided

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --drop-tables) drop_tables=true ;;
    --clean) clean=true ;;
    --help) show_help ;;
    --*) echo "Unknown option: $1" ; exit 1 ;;
    *) dump_file=$1 ;;
  esac
  shift
done

# Check if psql is installed and the version is compatible (15 or 16)
if [ ! -x "$(command -v psql)" ]; then
  echo "ERROR: psql is not installed."
  exit 1
fi

psql_version=$(psql -V | grep -o '[0-9]*\.[0-9]*' | head -1)
if [[ "$psql_version" == "15"* ]]; then
  echo "PostgreSQL 15 detected."
elif [[ "$psql_version" == "16"* ]]; then
  echo "PostgreSQL 16 detected."
else
  echo "WARNING: Unsupported PostgreSQL version $psql_version detected."
  echo "This script is designed to work with PostgreSQL 15 or 16."
  read -p "Do you want to continue anyway? [y/N]: " -r response
  if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Operation aborted."
    exit 1
  fi
  echo "Continuing with PostgreSQL $psql_version..."
fi

# Export password for authentication
export PGPASSWORD=$POSTGRES_PASSWORD

# Truncate all tables in the database
if $clean ; then
  tables=$(psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -t -c "SELECT tablename FROM pg_tables WHERE schemaname='public';")
  for table in $tables; do
    psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d $POSTGRES_DB -c "TRUNCATE TABLE \"$table\" CASCADE;"
  done
fi

# Drop all tables if needed
if $drop_tables ; then
  psql -h $POSTGRES_HOST \
    -p $POSTGRES_PORT \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
fi

# Execute psql to load the dump file or from stdin
if [ "$dump_file" = "-" ]; then
  psql -h $POSTGRES_HOST \
    -p $POSTGRES_PORT \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB
else
  psql -h $POSTGRES_HOST \
    -p $POSTGRES_PORT \
    -U $POSTGRES_USER \
    -d $POSTGRES_DB \
    -f "$dump_file"
fi
