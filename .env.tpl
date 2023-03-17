# Password for $MYSQL_USER
MYSQL_PASSWORD=
# SQL server host (default 127.0.0.1)
MYSQL_HOST=
# Variables below are defaulted in docker-compose.yml, you can set it here or in docker-compose.override.yml
#MYSQL_PORT=3306
#MYSQL_USER=root
# Cron time to run regular backups
#MYSQLBACKUP_CRON_TIME="30 3 * * *"
# Define folder to store backups, please create it befor use
#DUMP_PATH=backups
# Name of external docker network used in docker-compose.override.yml so you can connect to external network
# see test/docker-compose.yml for example creating external network
MYSQL_DOCKER_NETWORK=mysqlnetwork
# RocketChat URL
RC_URL="https://chat.example.com/hooks/e9bbde8000744596a60a2ef2d8c96012"
# RocketChat message
RC_DATA="{ "text": "MySQL backup OK" }"
# Icinga2 credentials (user:password)
IC_CREDENTIALS="apiuser:apipassword"
# Icinga2 URL
IC_URL="https://monitoring.example.com:5665/v1/actions/process-check-result"
# Icinga2 payload (see https://icinga.com/docs/icinga-2/latest/doc/08-advanced-topics/#external-check-results) 
IC_DATA="{ "type": "Service", "filter": "host.name==\"example-backup-checks\" && service.name==\"example-backup\"", "exit_status": 0, "plugin_output": "MySQL backup OK", "ttl": "87000"}"
