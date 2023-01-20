#!/bin/bash

MYSQL_CONN_STRING="-h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -P $MYSQL_PORT"
OUTPUTDIR="/var/backups/mysql"
MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"

EXTENSION="dump"
REMOVEDUPLICATE=1

renice -n 10 --pid $$ &>/dev/null

#Set lower io priority
[ -x /usr/bin/ionice ] && /usr/bin/ionice -c 3 -p $$ &>/dev/null || true 

set -eu

function mygrants () {
  mysql $MYSQL_CONN_STRING $@ -N -e "SELECT DISTINCT CONCAT('SHOW GRANTS FOR \'', user, '\'@\'', host, '\';') AS query FROM mysql.user" | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/## \1 ##/;/##/{x;p;x;}'
} 

function dedupe { 
local currentDump="$1"
local lastDump="$2"
if [ -n "$lastDump" ]; then
        if cmp "$currentDump" "$lastDump" &>/dev/null ;
        then
#               echo "Files $currentDump and $lastDump are same."
                if [ "$REMOVEDUPLICATE" -eq 1 ]; then
                        rm "$currentDump"
                fi
        fi
fi
} 

function rotate {
/usr/sbin/logrotate -f /etc/imt-sql-backup/rotate-mysql
}


if [ -r /etc/default/imt-sql-backup ]; then
        source /etc/default/imt-sql-backup
fi

#if ! [ -d $(dirname ${CONFIGFILE}) ]; then
#        # Mysql probably not installed, exiting
#        exit 0
#fi

if ! [ -d $OUTPUTDIR ]; then
        echo "$OUTPUTDIR doesnt exist! I will create."
        mkdir $OUTPUTDIR
fi

# Backup grants
currentDump="$OUTPUTDIR/grants.$EXTENSION"
mygrants | bzip2 -z > "$currentDump"
lastDump=$(ls $OUTPUTDIR/grants*.bz2 2>/dev/null | head -1)
dedupe "$currentDump" "$lastDump"
rotate

# get a list of databases
databases=$(mysql $MYSQL_CONN_STRING -e "SHOW DATABASES;" | tr -d "| " | egrep -v 'Database|information_schema|performance_schema')

#dump each database
for db in $databases; do
        currentDump="$OUTPUTDIR/$db.$EXTENSION"
        mysqldump $MYSQL_CONN_STRING --force --single-transaction --skip-lock-tables --databases $db | bzip2 -z > "$currentDump"
        lastDump=$(ls $OUTPUTDIR/$db*.bz2 2>/dev/null | head -1)
        dedupe "$currentDump" "$lastDump"
done