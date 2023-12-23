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

# Check if psql is installed and the version is 15
psql_version=$(psql -V | grep -o '[0-9]*\.[0-9]*' | head -1)
if [ ! -x "$(command -v psql)" ] || [[ "$psql_version" != "15"* ]]; then
  echo "psql is not installed or is not version 15."
  read -p "Do you want to install PostgreSQL 15? [y/N]: " -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    ./install-postgresql15.sh
    if [[ "$psql_version" == "15"* ]]; then
      echo "PostgreSQL 15 installed successfully."
    else
      echo "Failed to install PostgreSQL 15."
      exit 1
    fi
  else
    echo "PostgreSQL 15 installation aborted."
    exit 1
  fi
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
