MYSQL_PASSWORD=
MYSQL_HOST=
#Variables below are defaulted in docker-compose.yml, you can set it here or in docker-compose.override.yml
#MYSQL_PORT=3306
#MYSQL_USER=root
#CRON_TIME="30 3 * * *"
# Define folder to store backups, please create it befor use
# DUMP_PATH=backups
# Name of external docker network used in docker-compose.override.yml so you can connect to external network
# see test/docker-compose.yml for example creating external network
MYSQL_DOCKER_NETWORK=mysqlnetwork
