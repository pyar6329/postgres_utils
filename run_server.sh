#!/bin/bash

set -e

POSTGRES_DATA="${PWD}/data"
POSTGRES_INITDB="${PWD}/initdb"

OS_NAME="$(uname -s)"

if ! [ -e "${POSTGRES_DATA}" ]; then
  mkdir -p ${POSTGRES_DATA}
fi

case ${OS_NAME} in
  "Darwin" )
    docker run -it \
      -d \
      --rm \
      --name "postgres" \
      -p "${POSTGRES_PORT:-5432}:5432" \
      -e "POSTGRES_DB=${POSTGRES_DATABASE:-dsf_api}" \
      -e "POSTGRES_USER=${USER}" \
      -e "POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}" \
      -e "TZ=UTC" \
      -e "LANG=C.UTF-8" \
      -e "LC_ALL=C.UTF-8" \
      -e "PGDATA=/data" \
      -v "${POSTGRES_INITDB}:/docker-entrypoint-initdb.d" \
      -v "${POSTGRES_DATA}:/data" \
      postgres:14.5 postgres \
      -c log_destination=stderr \
      -c log_statement=all \
      -c log_connections=on \
      -c log_disconnections=on
    ;;
  * )
    docker run -it \
      -d \
      --rm \
      --name "postgres" \
      -p "${POSTGRES_PORT:-5432}:5432" \
      -e "POSTGRES_DB=${POSTGRES_DATABASE:-dsf_api}" \
      -e "POSTGRES_USER=${USER}" \
      -e "POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}" \
      -e "PGDATA=/data" \
      -e "TZ=UTC" \
      -e "LANG=C.UTF-8" \
      -e "LC_ALL=C.UTF-8" \
      -u $(id -u ${USER}):$(id -g ${USER}) \
      -v /etc/passwd:/etc/passwd:ro \
      -v /etc/group:/etc/group:ro \
      -v "${POSTGRES_INITDB}:/docker-entrypoint-initdb.d" \
      -v "${POSTGRES_DATA}:/data" \
      postgres:14.5 postgres \
      -c log_destination=stderr \
      -c log_statement=all \
      -c log_connections=on \
      -c log_disconnections=on
    ;;
esac

# log_destination: ログの出力先
# log_statement: クエリをログに出力する
# log_connections: コネクション接続時にログを出力する
# log_disconnections: コネクション切断時にログを出力する
