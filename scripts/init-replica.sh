#!/bin/bash
set -e

echo "Configuring PostgreSQL Replica..."

# Clean existing data
rm -rf /var/lib/postgresql/data/*

# Copy data from the primary
rsync -a postgres_primary:/archive/ /var/lib/postgresql/data/

# Configure replication
echo "standby_mode = 'on'" > /var/lib/postgresql/data/recovery.conf
echo "primary_conninfo = 'host=postgres_primary port=5432 user=replica password=replicapassword'" >> /var/lib/postgresql/data/recovery.conf
echo "trigger_file = '/tmp/postgresql.trigger'" >> /var/lib/postgresql/data/recovery.conf

chown postgres:postgres /var/lib/postgresql/data/recovery.conf

echo "Replica configuration complete."
