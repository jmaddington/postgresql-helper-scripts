# PostgreSQL Helper Scripts

This repository contains scripts for managing PostgreSQL databases within a Docker environment where PostgreSQL configuration is defined through environment variables.

## Prerequisites

- Docker
- PostgreSQL environment variables set (e.g., `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`)

## Config

The project assumes that you have the following variables defined in your environment,
which is what we'd expect if you are running this from inside a Docker container.

```bash
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=yourpassword
POSTGRES_DB=yourdatabase
```

## Scripts

### `install-postgresql15.sh`

Installs PostgreSQL 15 on your system.

### `load-db.sh`

Loads a PostgreSQL database dump using the environment variables and a specified dump file or standard input.

Options:

- `--drop-tables`: Drop all tables before loading the dump.
- `--clean`: Truncate all tables in the public schema before loading the dump.
- `--help`: Display help message.

### `dump-db.sh`

Dumps the PostgreSQL database using the current environment variables.

Options:

- `--data-only`: Dump only the data, no schema.
- `--no-owner`: Do not output commands to set ownership of objects.
- `--no-acl`: Prevent dumping of access privileges (grant/revoke).
- `--help`: Display help message.

## License

This project is licensed under the GNU General Public License v2.0 - see the [LICENSE](./LICENSE) file for details.
