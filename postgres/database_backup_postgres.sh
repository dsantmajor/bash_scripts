#! /usr/bin/env bash
# Perform a backup and restore for a postgres Database.
#
#Inspired by : http://chuck:7990/projects/COPPER/repos/copper-backup-scripts/browse/psql-exports/backup-remote-postgres.pl

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
DBPASSWORD="xxx123"
BACKUP_DIR_DATE=`date +"%Y-%m-%d"`
BACKUP_DIR_HNAS="${BACKUP_DIR_REMOTE}/${BACKUP_DIR_DATE}/"

set +x
#echo $BACKUP_PATH

# set -e
#
# USAGE=$(cat <<USAGE
# Usage: $0 <options>
#
# This script performs a backup and restore of a postgres DB
#
# Options:
#
#   -h  | --help                Display this message
#
#   -b  | --backup              Performs a DB backup when -b option is used along
#                               with the following variables schema_name,hostname,
#                               username & password
#                               EXAMPLE : backup -b hostname db_name username password
#
#   -r  | --restore             Use pg_restore to perform a DB restore
#   -c  | --cleanup             Cleans up and deletes any files
#
#
# Additional options:
#
#  - remote_location  - Used to specify remote location to place the backup
# USAGE
# )
#
# while [ $# -gt 0 ]; do
#   case "$1" in
#     -h | --help)
#       echo "$USAGE"; exit 2; shift;;
#     -b | --backup)
#       BACKUP_INITIATE=1; shift 1;;
#       #HOSTNAME=$2; DB_NAME=$3; USERNAME=$4; DBPASSWORD=$5; shift 2;;
#     -c | --cleanup)
#       CLEANUP=1; shift 1;;
#     -*) echo "Invalid argument $1"; exit 1;;
#     *) break;;
#   esac
# done
#
# if [ -n "$CLEANUP" ]; then
#   set +e
#   echo " todo Cleanup"
#   exit 0
# fi
#
# if [ -n "$BACKUP_INITIATE" ]; then
#   if [ $# -ne 5 ];then
#     echo "--------------------------------------"
#     echo "ERROR"
#     echo "--------------------------------------"
#     echo "Please provide the details as per Help"
#     echo "--------------------------------------"
#
#     echo "$USAGE"; exit 2
#   fi
#   echo "Initiating Postgres backup using pg_dump"
#   export HOSTNAME=$2;
#   export DB_NAME=$3;
#   export USERNAME=$4;
#   export DBPASSWORD=$5
# else
#   echo "$USAGE"; exit 2
#
# fi



# A function to draw a line to help highlight a message when you call this with an
# agrument example call_drawline Don the oputput will be as shown below
#    -------------
#    | Don        |
#    -------------
#
drawline () {
  declare line=""
  declare char="-"
  for (( i=0; i<len; ++i )); do
    line="${line}${char}"
  done
  printf "%s\n" "$line"
}

# no arguments? no output

call_drawline () {

  [[ ! $1 ]] && exit 0

  declare -i len="${#1} + 4"
  drawline len
  printf "| %s |\n" "$1"
  drawline len

}


# A function to capture time in a desired format
# We will use this function to set the START_TIME and END_TIME
# START_TIME=$(timestamp)
# END_TIME=$(timestamp)

timestamp() {
echo "`date +"%Y-%m-%d:%H:%M:%S"`"
}


# A function to convert time into seconds
# we will echo the output of START_TIME ,using the : as a seperator ,and break it down into date, hour ,min ,sec (d h m s)
# then convert the value of ( h m s ) it into seconds
# use it like this : convert_time_to_sec $START_TIME
convert_time_to_sec() {
  read -r d h m s <<< $(echo $1 | tr ':' ' ' )
  echo $(((h*60*60)+(m*60)+s))
}


# A function to calculate the time taken in seconds
# to use this we need two arguments START_TIME END_TIME
# time_taken_in_sec $START_TIME $END_TIME
time_taken_in_sec() {

  START_TIME_SEC=$(convert_time_to_sec $1)
  END_TIME_SEC=$(convert_time_to_sec $2)
  DIFF=$((START_TIME_SEC-END_TIME_SEC))

  echo "$((DIFF/60))m $((DIFF%60))s"

}

check_file_name () {

  if [[ -e ${1} ]]; then
    file_name=`echo $1 | rev | cut -d '/' -f 1 | rev`
    call_drawline "      ERROR      "
    echo " File already exists: $file_name "
    echo " Now exiting"
    exit 1
  fi

}

backup_postgres () {

  # Create file path
  START_TIME=$(timestamp)
  echo " "
  echo " START_TIME: ${START_TIME}"
  export PGPASSWORD=$DBPASSWORD
  export PGPASSFILE=${CUR_DIR}/.pgpass
  BACKUP_DIR_LOCAL="/tmp"
  BACKUP_FILENAME="${BACKUP_DIR_LOCAL}/${START_TIME}_${DB_NAME}.backup"
  check_file_name ${BACKUP_FILENAME}
  drawline " Starting DataBase backup: Postgres"
  echo " Local Backup location: $BACKUP_FILENAME "

  if pg_dump -h ${HOSTNAME} -U ${USERNAME} ${DB_NAME} --clean --if-exists --format=custom > ${BACKUP_FILENAME}; then
    call_drawline "DB_NAME: ${DB_NAME} "
    echo " Creating new backup for DB--> ${DB_NAME} && dumping it to location: ${BACKUP_FILENAME}"
    echo " Postgres Dumped Successfully at: ${BACKUP_FILENAME}"
    END_TIME=$(timestamp)
    echo " "
    echo " END_TIME : ${END_TIME}"
    echo " "
    TIME_TAKEN=$(time_taken_in_sec $START_TIME $END_TIME)
    echo " "
    call_drawline " Time taken to Backup: ${TIME_TAKEN}"
    echo " "
  else
    call_drawline "      ERROR      "
    echo " Could not perform Postgres Dump: ${BACKUP_FILENAME}"
    call_drawline " Exiting now"
    exit 1
  fi

}



transfer_backup_to_hnas () {
  echo " About to begin Transfer"
  START_TIME=$(timestamp)
  echo " "
  echo " START_TIME: ${START_TIME}"
  echo " "
  create_dir ${BACKUP_DIR_HNAS}
  call_drawline " Transfering ${BACKUP_FILENAME} to ${BACKUP_DIR_HNAS}"
  if mv ${BACKUP_FILENAME} ${BACKUP_DIR_HNAS}; then
    echo " Transfering Local Postgres Dump to Remote Shared Dirive"
    echo " Postgres Dump Successfully transferred to: ${BACKUP_DIR_HNAS}"
    END_TIME=$(timestamp)
    echo " "
    echo " END_TIME: ${END_TIME}"
    echo " "
    TIME_TAKEN=$(time_taken_in_sec $START_TIME $END_TIME)
    echo " "
    echo " Time taken to transfer: ${TIME_TAKEN}"
  else
    call_drawline "      ERROR      "
    echo " Could not transfer Local Postgres Dump to Remote location: ${BACKUP_DIR_HNAS}"
    call_drawline " Exiting now"
    exit 1
  fi
}



# function that checks if a given directory exists if not it tries to creat it.
create_dir() {

  if [[ ! -d "${1}" ]]; then

    echo " Directory ${1} does not exist"

    if mkdir -p "${1}"; then

      echo " Creating new directory: ${1}"
      echo " Directory created: ${1} "

    else
      call_drawline "      ERROR      "

      echo " Could not create ${1} directory"

      call_drawline " Exiting now"
      exit 1
    fi
  else

    echo " Directory already exists: at ${1} "
    echo " Requirements already satisfied: Noting to do here ,proceeding with other steps !!"
    # call_drawline " Thank you"
  fi
}

call_drawline "Postgres Backup Starting"
backup_postgres

transfer_backup_to_hnas
call_drawline "Backup Completed"
