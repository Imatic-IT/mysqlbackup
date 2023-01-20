#!/bin/bash

if [ ! -f /etc/cron.d/mysql-backup ]; then
        # Add cron.d file
        echo "${CRON_TIME} root /etc/imt-sql-backup/mysql-backup.sh" > /etc/cron.d/mysql-backup
fi

service cron start
sleep infinity