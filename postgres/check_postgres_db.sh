#! /usr/bin/env bash
# This script will run few tests and checks on a postgres Database to ensure we
# have a baseline to compare results before and after the migration ( backup and restore)


# declaring the script directory
set -x
CUR_DIR=$(cd `dirname $0` && pwd)
echo $CUR_DIR
BACKUP_DIR_LOCAL="/tmp"
#BACKUP_DIR_REMOTE="/mnt/hnas/backups/$HOSTNAME/postgres-exports"
BACKUP_DIR_REMOTE="/Users/donsantmajor/code/postgres/postgres_data"
DB_NAME="postgres"
HOSTNAME="127.0.0.1"
USERNAME="postgres"
DBPASSWORD="xxxxx"
BACKUP_DIR_DATE=`date +"%Y-%m-%d"`
BACKUP_DIR_HNAS="${BACKUP_DIR_REMOTE}/${BACKUP_DIR_DATE}/"
TABLE_NAME=""


# Count number of records in a table
#
# psql  -h 127.0.0.1 -U postgres -d ibisdbstaging  -Atc "SELECT COUNT(*) FROM bmi;"
#
#
# list all schemas
#
# psql  -h 127.0.0.1 -U postgres -Atc "select nspname from pg_catalog.pg_namespace; "
#
# List only tables
#
# psql  -h 127.0.0.1 -U postgres -d ibisdbstaging  -Atc "SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';"
#
# List tables in the current Database
#
# psql  -h 127.0.0.1 -U postgres -d ibisdbstaging  -Atc "SELECT table_schema,table_name FROM information_schema.tables ORDER BY table_schema,table_name;"
#
# List all databses
#
# psql  -h 127.0.0.1 -U postgres -d ibisdbstaging  -Atc "SELECT datname FROM pg_database WHERE datistemplate = false;"


count_records () {

psql  -h $HOSTNAME -U $USERNAME -d $DB_NAME  -Atc "SELECT COUNT(*) FROM $(TABLE_NAME);"

}
