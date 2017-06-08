#!/bin/bash

#strict mode
set -euo pipefail
IFS=$'\n\t'

if [ -e reference/*.backup ]; then
    DEFAULT_BACKUP=$(ls -1t ./reference/*.backup | head -1)
else
    DEFAULT_BACKUP=/tmp/ibis.backup
fi

database=${1:-IbisDbDev}
backup="${2:-$DEFAULT_BACKUP}"
host=${3:-localhost}
port=${4:-5432}
username=${5:-postgres}
verbose=
#verbose=--verbose

SQL_OPTIONS="--host=${host} --port=${port} --username=${username}"
RESTORE_OPTIONS="${SQL_OPTIONS} ${verbose} --dbname ${database}"

echo "Using ${SQL_OPTIONS} to drop and create ${database}"

createuser ibisdbuser &> /dev/null || true

eval psql ${SQL_OPTIONS} postgres -o /dev/null <<-EOF
  SET client_min_messages = ERROR;
  SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity
  WHERE pg_stat_activity.datname = '${database}'
    AND pid <> pg_backend_pid();
  DROP DATABASE IF EXISTS "${database}";
  CREATE DATABASE "${database}" WITH OWNER = ibisdbuser;
EOF

echo "Using ${RESTORE_OPTIONS} to restore ${backup} to ${database}"
echo "Restoring schema backup from ${backup}"
eval pg_restore ${RESTORE_OPTIONS} \
  --exit-on-error --schema-only --no-privileges --no-tablespaces \
  ${backup}

echo "Restoring sequences from ${backup}"
list=./seq.list
pg_restore --list ${backup} | grep "SEQUENCE SET" > ${list}
eval pg_restore ${RESTORE_OPTIONS} --use-list=${list} ${backup}
rm ${list}

echo "Restoring reference data from ${backup} 1/3"
eval pg_restore ${RESTORE_OPTIONS} \
  --exit-on-error --data-only \
  -t industry -t brand \
  ${backup}

echo "Restoring reference data from ${backup} 2/3"
eval pg_restore ${RESTORE_OPTIONS} \
  --exit-on-error --data-only \
  -t quote_pricing_configuration -t motor_cover_configuration \
  -t vehicle_identification \
  ${backup}

echo "Restoring reference data from ${backup} 3/3"
eval pg_restore ${RESTORE_OPTIONS} \
  --exit-on-error --data-only \
  -t cover_section -t address -t agency -t anzsic_code -t banned_abn \
  -t banned_ip_address -t bmi -t bsb -t business_rule -t construction_category \
  -t databasechangelog -t databasechangeloglock -t excess_amount \
  -t finance_company -t liability_suggestion -t location \
  -t motor_cover_defaults -t motor_cover_options -t occupation \
  -t occupation_type -t occupation_type_question -t option_slider \
  -t promotion_code -t regular_outage -t role -t scheduled_outage \
  -t user -t user_role -tvehicle_additional_excess \
  -t vehicle -t industry_section_type_configuration \
  ${backup}

echo "Creating Test Users for TAM"
eval psql --quiet ${SQL_OPTIONS} ${database} < createTestUsers.sql

echo "${database} is ready for use on ${host}:${port}"
echo "jdbc:postgresql://${host}:${port}/${database}"
