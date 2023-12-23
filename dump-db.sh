#!/bin/bash

# Script to dump PostgreSQL database using the current environment variables.

# Help message
show_help() {
  echo "Usage: $0 [OPTION]..."
  echo "Dump PostgreSQL database using environment variables."
  echo
  echo "Options:"
  echo "  --data-only    Dump only the data, no schema."
  echo "  --no-owner     Do not output commands to set ownership of objects."
  echo "  --no-acl       Prevent dumping of access privileges (grant/revoke)."
  echo "  --help         Display this help and exit."
  echo
  exit 0
}

# Check for help flag
for arg in "$@"; do
  case $arg in
    --help)
      show_help
      ;;
  esac
done

# Check if pg_dump is installed and the version is 15
if ! pg_dump -V 2>&1 | grep -q "15"; then
  echo "pg_dump is not installed or is not version 15."
  read -p "Do you want to install PostgreSQL 15? [y/N]: " -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    ./install-postgresql15.sh
    # Re-check the version after installation
    pg_dump_version=$(pg_dump -V | grep -o '[0-9]*\.[0-9]*' | head -1)
    if [[ "$pg_dump_version" == "15"* ]]; then
      echo "PostgreSQL 15 installed successfully."
    else
      echo "Failed to install PostgreSQL 15."
      exit 1
    fi
  else
    echo "PostgreSQL 15 installation aborted."
    exit 1
  fi
else
  echo "pg_dump version 15 is already installed."
fi

# Export password for authentication
export PGPASSWORD="$POSTGRES_PASSWORD"

# Execute pg_dump with flags
pg_dump -h "$POSTGRES_HOST" \
  -p "$POSTGRES_PORT" \
  -U "$POSTGRES_USER" \
  "${@}" \
  "$POSTGRES_DB"
