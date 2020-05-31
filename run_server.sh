#!/bin/bash

set -e

POSTGRES_DATA="${PWD}/data"

if ! [ -e "${POSTGRES_DATA}" ]; then
  mkdir -p ${POSTGRES_DATA}
fi

docker run -it \
  -d \
  --rm \
  --name "postgres" \
  -p "${POSTGRES_PORT:-5432}:${POSTGRES_PORT:-5432}" \
  -e "POSTGRES_DB=${POSTGRES_DATABASE:-dsf_api}" \
  -e "POSTGRES_USER=${USER}" \
  -e "POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}" \
  -e "PGDATA=/data" \
  -u $(id -u ${USER}):$(id -g ${USER}) \
  -v /etc/passwd:/etc/passwd:ro \
  -v /etc/group:/etc/group:ro \
  -v "${POSTGRES_DATA}:/data" \
  postgres:11

