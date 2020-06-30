#!/bin/bash

set -e

POSTGRES_DATA="${PWD}/data"
POSTGRES_INITDB="${PWD}/initdb"

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
  -v "${POSTGRES_INITDB}:/docker-entrypoint-initdb.d" \
  -v "${POSTGRES_DATA}:/data" \
  postgres:11 postgres \
  -c log_destination=stderr \
  -c log_statement=all \
  -c log_connections=on \
  -c log_disconnections=on

# log_destination: ログの出力先
# log_statement: クエリをログに出力する
# log_connections: コネクション接続時にログを出力する
# log_disconnections: コネクション切断時にログを出力する
