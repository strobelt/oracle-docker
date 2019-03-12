#!/bin/sh

# basic parameters
ORACLE_DIR=/home/oracle
LOG_FILE=$ORACLE_DIR/setup/log/runInitialScripts.log
SETUP_FILE=$ORACLE_DIR/setup/.sqlinitdone
ERROR_FILE=$ORACLE_DIR/setup/.sqliniterror
BASH_RC=$ORACLE_DIR/.bashrc
source ${BASH_RC}

function run_script {
  echo "Running script $1"
  sqlplus -S / as sysdba @"$1" 2>&1 >> $LOG_FILE
  grep -q -P "\(ORA-\)\|\(OPW-\)|SP2-" $LOG_FILE
  if [ $? -eq 0 ];
  then
    >&2 echo "Failed to run script $1"
    echo "Failed to run script $1" >> $LOG_FILE
    touch $ERROR_FILE
    exit 1
  else
    echo "Script $1 ran successfully"
    echo "Script $1 ran successfully" >> $LOG_FILE
  fi
}


for filename in /volume/*.sql; do
    [ -e "$filename" ] || continue
    echo exit | run_script $filename
    ret=$?
    if [ $ret -ne 0 ];
    then
      >&2 echo "Failed to run scripts"
      echo "Failed to run scripts" >> $LOG_FILE
      >&2 echo "Log file available on $LOG_FILE"
      exit 1
    fi
done

touch $SETUP_FILE
echo "Success"
echo "Success" >> $LOG_FILE
