#!/bin/bash

# backup each mysql db into a different file, rather than one big file
# as with --all-databases - will make restores easier

renice -p 10 --pid $$ &>/dev/null

#Set lower io priority
[ -x /usr/bin/ionice ] && /usr/bin/ionice -c 3 -p $$ &>/dev/null || true 

set -eu

function mygrants() #{{{
{
  mysql $@ -B -N -e "SELECT DISTINCT CONCAT(
    'SHOW GRANTS FOR \'', user, '\'@\'', host, '\';'
    ) AS query FROM mysql.user" | \
  mysql $@ | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/## \1 ##/;/##/{x;p;x;}'

} #}}}

function dedupe { #{{{
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
} #}}}

function rotate {
/usr/sbin/logrotate -f /etc/imt-sql-backup/rotate-mysql
}
OUTPUTDIR="/var/backups/mysql"
MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"
CONFIGFILE="/etc/mysql/debian.cnf"
#Configfile is obsolete now, but keep it for backwards compatibility
if [ -r $CONFIGFILE ]; then
  #Parse user variable section client from ini file - $CONFIGFILE
  # see https://stackoverflow.com/questions/6318809/how-do-i-grab-an-ini-value-within-a-shell-script
  section=client
  variable=user
  user=$(cat "$CONFIGFILE" | sed -nr "/^\[${section}\]/ { :l /^${variable}[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}")
  MYSQLCONNECTION="--defaults-file=$CONFIGFILE -u $user"
else
  #File is not readable, fallback to root user, which is used in future mysql releases, because is authenticated
  MYSQLCONNECTION="-u root"
fi
#Don't use plain bz2 extension due to logrotate
EXTENSION="dump"
REMOVEDUPLICATE=1

if [ -r /etc/default/imt-sql-backup ]; then
        source /etc/default/imt-sql-backup
fi

if ! [ -d $(dirname ${CONFIGFILE}) ]; then
        # Mysql probably not installed, exiting
        exit 0
fi

if ! [ -d $OUTPUTDIR ]; then
        echo "$OUTPUTDIR doesnt exist! I will create."
        mkdir $OUTPUTDIR
fi

# Backup grants
currentDump="$OUTPUTDIR/grants.$EXTENSION"
mygrants $MYSQLCONNECTION | bzip2 -z > "$currentDump"
lastDump=$(ls $OUTPUTDIR/grants*.bz2 2>/dev/null | head -1)
dedupe "$currentDump" "$lastDump"
rotate

# get a list of databases
databases=$($MYSQL ${MYSQLCONNECTION} -e "SHOW DATABASES;" | tr -d "| " | egrep -v 'Database|information_schema|performance_schema')

# dump each database
for db in $databases; do
#        echo $db
        currentDump="$OUTPUTDIR/$db.$EXTENSION"
        $MYSQLDUMP ${MYSQLCONNECTION} --force --single-transaction --skip-dump-date --skip-comments --opt --databases --events $db | bzip2 -z > "$currentDump"
        set +e
        lastDump=$(ls $OUTPUTDIR/$db*.bz2 2>/dev/null | head -1)
        dedupe "$currentDump" "$lastDump"
        rotate
        set -e
done
