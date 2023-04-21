#!/bin/bash

# add cron file
echo "${MYSQLBACKUP_CRON_TIME} root /etc/imt-sql-backup/mysql-backup.sh > /var/log/mysql-backup.log 2>&1" > /etc/cron.d/mysql-backup

# make env variables available in cron jobs
env > /etc/environment

#start cron service and keep container running
service cron start
sleep infinity
