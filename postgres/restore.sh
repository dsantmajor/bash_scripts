
#! /usr/bin/env bash

pg_restore -h 127.0.0.1 -U postgres -d ibisdbstaging < 2017-05-30-013754_IbisDbStaging.backup


Create
psql  -h 127.0.0.1 -U postgres -Atc "CREATE DATABASE IbisDbStaging"

Grant

psql  -h 127.0.0.1 -U postgres -Atc "GRANT ALL PRIVILEGES ON DATABASE IbisDbStaging TO postgres"


Revoke

 psql  -h 127.0.0.1 -U postgres -Atc "REVOKE CONNECT ON DATABASE dontest FROM public;"


Drop
psql  -h 127.0.0.1 -U postgres -Atc "DROP DATABASE IF EXISTS dontest"

Count number of records in a table

psql  -h 127.0.0.1 -U postgres -d ibisdbstaging  -Atc "SELECT COUNT(*) FROM bmi;"


list all schemas

psql  -h 127.0.0.1 -U postgres -Atc "select nspname from pg_catalog.pg_namespace; "

List only tables

psql  -h 127.0.0.1 -U postgres -d ibisdbstaging  -Atc "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';"

List tables in the current Database

psql  -h 127.0.0.1 -U postgres -d ibisdbstaging  -Atc "SELECT table_schema,table_name FROM information_schema.tables ORDER BY table_schema,table_name;"

List all databses

psql  -h 127.0.0.1 -U postgres -d ibisdbstaging  -Atc "SELECT datname FROM pg_database WHERE datistemplate = false;"
