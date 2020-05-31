#!/bin/bash

set -eu

PGPASSWORD=${PSQL_PASSWORD} psql -h ${PSQL_HOSTNAME} -p ${PSQL_PORT} -U ${PSQL_USERNAME} -w -d ${PSQL_DATABASE}
