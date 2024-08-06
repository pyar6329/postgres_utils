ARG POSTGRES_VERSION=14.11
FROM postgres:${POSTGRES_VERSION}

# ref: https://github.com/HypoPG/hypopg
ARG HYPOPG_VERSION="1.4.0"
# ref: https://github.com/supabase/index_advisor
ARG INDEX_ADVISOR_VERSION="0.2.0"

# ref: https://github.com/postgres/postgres
ARG POSTGRES_SOURCE_VERSION="14_11"

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    build-essential \
    postgresql-server-dev-14 \
    libreadline-dev \
    zlib1g-dev \
    flex \
    bison && \
  curl -sL -o hypopg.tar.gz https://github.com/HypoPG/hypopg/archive/refs/tags/${HYPOPG_VERSION}.tar.gz && \
  tar xzvf hypopg.tar.gz && \
  cd hypopg-${HYPOPG_VERSION} && \
  make && \
  make install && \
  cd .. && \
  rm -rf hypopg.tar.gz hypopg-${HYPOPG_VERSION} && \
  curl -sL -o index_advisor.tar.gz https://github.com/supabase/index_advisor/archive/refs/tags/v${INDEX_ADVISOR_VERSION}.tar.gz && \
  tar xzvf index_advisor.tar.gz && \
  cd index_advisor-${INDEX_ADVISOR_VERSION} && \
  make install && \
  cd .. && \
  rm -rf index_advisor.tar.gz index_advisor-${INDEX_ADVISOR_VERSION} && \
  curl -sL -o postgres_source.tar.gz "https://github.com/postgres/postgres/archive/refs/tags/REL_${POSTGRES_SOURCE_VERSION}.tar.gz" && \
  tar xzvf postgres_source.tar.gz && \
  cd postgres-REL_${POSTGRES_SOURCE_VERSION} && \
  ./configure && \
  cd contrib/auto_explain && \
  make && \
  make install && \
  cd ../../.. && \
  rm -rf postgres-REL_${POSTGRES_SOURCE_VERSION} postgres_source.tar.gz && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    curl \
    ca-certificates \
    build-essential \
    postgresql-server-dev-14 \
    libreadline-dev \
    zlib1g-dev \
    flex \
    bison && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

STOPSIGNAL SIGINT
EXPOSE 5432

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["postgres"]
