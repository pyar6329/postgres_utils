#!/bin/bash

set -e

# set below environment variables
# RESTORE_HOSTNAME="database hostname"
# RESTORE_PASSWORD="database password"
# RESTORE_PORT="database port"
# RESTORE_DATABASE="database name"
# RESTORE_USERNAME="database username"


# PGPASSWORD=${RESTORE_PASSWORD} psql \
#   -h ${RESTORE_HOSTNAME} \
#   -p ${RESTORE_PORT} \
#   -U ${RESTORE_USERNAME} \
#   -d ${RESTORE_DATABASE} \
#   -w \
#   -l \
#   --csv \
#   | awk -F ',' '{print $1}'

  # --no-align

# PGPASSWORD=${RESTORE_PASSWORD} psql \
#   -h ${RESTORE_HOSTNAME} \
#   -p ${RESTORE_PORT} \
#   -U ${RESTORE_USERNAME} \
#   -d ${RESTORE_DATABASE} \
#   -w \
#   -c "ANALYZE VERBOSE;"

# function get_databases {
#   PGPASSWORD=${RESTORE_PASSWORD} \
#   psql \
#     -h ${RESTORE_HOSTNAME} \
#     -p ${RESTORE_PORT} \
#     -U ${RESTORE_USERNAME} \
#     -d ${connected_db_name} \
#     -w \
#     --csv \
#     -c "select datname from pg_database;" \
#     | sed '1d'
# }

function run_some_query {
  PGPASSWORD=${RESTORE_PASSWORD} \
  psql \
    -h ${RESTORE_HOSTNAME} \
    -p ${RESTORE_PORT} \
    -U ${RESTORE_USERNAME} \
    -d ${connected_db_name} \
    -w \
    -c "select 1;"
}

function drop_database {
  PGPASSWORD=${RESTORE_PASSWORD} \
  psql \
    -h ${RESTORE_HOSTNAME} \
    -p ${RESTORE_PORT} \
    -U ${RESTORE_USERNAME} \
    -d ${connected_db_name} \
    -w \
    -c "drop database ${target_db_name};"
}

function create_database {
  PGPASSWORD=${RESTORE_PASSWORD} \
  psql \
    -h ${RESTORE_HOSTNAME} \
    -p ${RESTORE_PORT} \
    -U ${RESTORE_USERNAME} \
    -d ${connected_db_name} \
    -w \
    -c "create database ${target_db_name};"
}

function re_initialize_data {
  PGPASSWORD=${RESTORE_PASSWORD} \
  psql \
    -h ${RESTORE_HOSTNAME} \
    -p ${RESTORE_PORT} \
    -U ${RESTORE_USERNAME} \
    -d ${RESTORE_DATABASE} \
    -w \
    -c "create extension hypopg; create extension index_advisor cascade; create role postgres with login password 'postgres'; alter role postgres with superuser createrole createdb replication bypassrls; create role postgres_ro with login password 'postgres'; grant pg_read_all_data to postgres_ro;"
}

# This command is failed if connected database is not found
if ! $(connected_db_name="${RESTORE_DATABASE}" run_some_query > /dev/null 2>&1); then
  echo "This command cannot access to database (${RESTORE_DATABASE}). Please check to exist it"
  exit 1
fi

TEMPORARY_DATABASE="temporary_db"

# create temporary database
connected_db_name="${RESTORE_DATABASE}" \
  target_db_name="${TEMPORARY_DATABASE}" \
  create_database

# remove target database
connected_db_name="${TEMPORARY_DATABASE}" \
  target_db_name="${RESTORE_DATABASE}" \
  drop_database

# create target database
connected_db_name="${TEMPORARY_DATABASE}" \
  target_db_name="${RESTORE_DATABASE}" \
  create_database

# remove temporary database
connected_db_name="${RESTORE_DATABASE}" \
  target_db_name="${TEMPORARY_DATABASE}" \
  drop_database

# re-initialize data
re_initialize_data
