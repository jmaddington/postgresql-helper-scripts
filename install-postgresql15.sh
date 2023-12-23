#!/bin/bash

# Update package list
apt-get update

# Install wget if not installed
if ! command -v wget &> /dev/null; then
    apt-get install -y wget
fi

# Install gnupg if not installed
if ! command -v gpg &> /dev/null; then
    apt-get install -y gnupg
fi

# Install lsb-release if not installed
if ! command -v lsb_release &> /dev/null; then
    apt-get install -y lsb-release
fi

# Add PostgreSQL repository and its key
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql.gpg
echo "deb [signed-by=/usr/share/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list

# Update package list with the new repository
apt-get update

# Install PostgreSQL 15
apt-get install -y postgresql-15

# Check if installation was successful
psql_version=$(psql -V 2>&1 | grep -o '[0-9]*\.[0-9]*' | head -1)
if [[ "$psql_version" != "15"* ]]; then
    echo "Failed to install PostgreSQL 15."
    exit 1
else
  echo "PostgreSQL 15 installed successfully."
fi
