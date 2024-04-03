#!/bin/bash

set -e

ARGS="$@"
SCRIPT_DIR=$(echo $(cd $(dirname $0) && pwd))

POSTGRES_DATA="${SCRIPT_DIR}/data"
POSTGRES_INITDB="${SCRIPT_DIR}/initdb"


OS_NAME="$(uname -s)"

if ! [ -e "${POSTGRES_DATA}" ]; then
  mkdir -p ${POSTGRES_DATA}
fi

function run_postgres {
  # it create network when network is not found
  if ! $(docker network ls | grep ${DOCKER_NETWORK_NAME:-postgres} > /dev/null 2>&1); then
    docker network create ${DOCKER_NETWORK_NAME:-postgres}
    echo "postgres network () was created. Please check 'docker network ls'"
  fi

  if $(docker ps -a | grep postgres > /dev/null 2>&1); then
    echo "postgres container was already running."
  else
    case "${OS_NAME}" in
      "Darwin" )
        docker run -it \
          -d \
          --name "postgres" \
          --restart always \
          --cpus="2" \
          --memory=1024mb \
          --network "${DOCKER_NETWORK_NAME:-postgres}" \
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
          postgres:14.11 postgres \
          -c log_destination=stderr \
          -c log_statement=all \
          -c log_connections=on \
          -c log_disconnections=on
        ;;
      * )
        docker run -it \
          -d \
          --name "postgres" \
          --restart always \
          --cpus="2" \
          --memory=1024mb \
          --network "${DOCKER_NETWORK_NAME:-postgres}" \
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
          postgres:14.11 postgres \
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
  fi
}

function shutdown_postgres {
  # The process is killed if process exists
  if $(docker ps -a | grep postgres > /dev/null 2>&1); then
    docker rm -vf postgres
  else
    echo "postgres server was already downed"
  fi

  # The network is removed if network exists
  if $(docker network ls | grep ${DOCKER_NETWORK_NAME:-postgres} > /dev/null 2>&1); then
    docker network rm -f ${DOCKER_NETWORK_NAME:-postgres}
  else
    echo "postgres network (${DOCKER_NETWORK_NAME:-postgres}) was already deleted"
  fi
}

case "${ARGS}" in
  "--up" )
    run_postgres
    ;;
  "--down" )
    shutdown_postgres
    ;;
  * )
    echo "argument is required. Please set '--up' or '--down'"
    ;;
esac
