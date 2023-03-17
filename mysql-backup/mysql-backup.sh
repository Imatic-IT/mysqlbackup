#!/bin/bash

mysql_conn_string="-h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD -P $MYSQL_PORT"
outputdir="/var/backups/mysql"
extension="dump"
removeduplicate=1

renice -n 10 --pid $$ &>/dev/null

#Set lower io priority
[ -x /usr/bin/ionice ] && /usr/bin/ionice -c 3 -p $$ &>/dev/null || true 

set -eu

function mygrants () {
  mysql $mysql_conn_string $@ -N -e "SELECT DISTINCT CONCAT('SHOW GRANTS FOR \'', user, '\'@\'', host, '\';') AS query FROM mysql.user" | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/## \1 ##/;/##/{x;p;x;}'
} 

function dedupe { 
local currentDump="$1"
local lastDump="$2"
if [ -n "$lastDump" ]; then
        if cmp "$currentDump" "$lastDump" &>/dev/null ;
        then
#               echo "Files $currentDump and $lastDump are same."
                if [ "$removeduplicate" -eq 1 ]; then
                        rm "$currentDump"
                fi
        fi
fi
} 

function rotate {
/usr/sbin/logrotate -f /etc/imt-sql-backup/rotate-mysql
}


# if [ -r /etc/default/imt-sql-backup ]; then
#         source /etc/default/imt-sql-backup
# fi

#if ! [ -d $(dirname ${CONFIGFILE}) ]; then
#        # Mysql probably not installed, exiting
#        exit 0
#fi

if ! [ -d $outputdir ]; then
        echo "$outputdir doesnt exist! I will create."
        mkdir $outputdir
fi

# Backup grants
currentDump="$outputdir/grants.$extension"
mygrants | bzip2 -z > "$currentDump"
lastDump=$(ls $outputdir/grants*.bz2 2>/dev/null | head -1)
dedupe "$currentDump" "$lastDump"
rotate

# get a list of databases
databases=$(mysql $mysql_conn_string -e "SHOW DATABASES;" | tr -d "| " | egrep -v 'Database|information_schema|performance_schema')

#dump each database
for db in $databases; do
        currentDump="$outputdir/$db.$extension"
        mysqldump $mysql_conn_string --force --single-transaction --skip-lock-tables --max-allowed-packet=64M --databases $db | bzip2 -z > "$currentDump"
        lastDump=$(ls $outputdir/$db*.bz2 2>/dev/null | head -1)
        dedupe "$currentDump" "$lastDump"
done

# send a message to rocketchat (only if the URL is set)
if [ -z "$RC_URL" ]; then
  curl -sS -H ''Content-Type: application/json' -d '"$RC_DATA"' - status OK" }' "$RC_URL"
fi

# send a check result to icinga (only if the URL is set)
if [ -z "$IC_URL" ]; then
  curl -k -sS -u "$IC_CREDENTIALS" -H 'Accept: application/json' -X POST '"$IC_URL"' -d '"$IC_DATA"'
fi
