create extension hypopg;
create extension index_advisor cascade;
create user postgres with password 'postgres';
alter role postgres with superuser createrole createdb replication bypassrls;
