create extension hypopg;
create extension index_advisor cascade;
create role postgres with login password 'postgres';
alter role postgres with superuser createrole createdb replication bypassrls;
create role postgres_ro with login password 'postgres';
grant pg_read_all_data to postgres_ro;
