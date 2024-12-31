#!/bin/bash
set -e

# Initialize the primary PostgreSQL instance
echo "Configuring PostgreSQL Primary..."

# Set up WAL archiving
echo "archive_mode = on" >> /etc/postgresql/postgresql.conf
echo "archive_command = 'cp %p /archive/%f'" >> /etc/postgresql/postgresql.conf
echo "max_wal_senders = 3" >> /etc/postgresql/postgresql.conf
echo "wal_level = replica" >> /etc/postgresql/postgresql.conf
echo "hot_standby = on" >> /etc/postgresql/postgresql.conf

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  CREATE USER replica REPLICATION LOGIN ENCRYPTED PASSWORD 'replicapassword';
  SELECT pg_start_backup('initial_backup');
EOSQL

rsync -a /var/lib/postgresql/data/ /archive/

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  SELECT pg_stop_backup();
EOSQL

echo "Primary configuration complete."