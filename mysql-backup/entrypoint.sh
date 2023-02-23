#!/bin/bash

# add cron file
if [ ! -f /etc/cron.d/mysql-backup ]; then
        # Add cron.d file
        echo "${MYSQLBACKUP_CRON_TIME} root /etc/imt-sql-backup/mysql-backup.sh >> /var/log/mysql-backup.log 2>&1" > /etc/cron.d/mysql-backup
fi

# make env variables available in cron jobs
env > /etc/environment

#start cron service and keep container running
service cron start
sleep infinity
