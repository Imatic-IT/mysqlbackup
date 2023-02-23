# mysqlbackup
Image for regular MySQL / MariaDB backup. You can run it to backup regular (non-docker) SQL instance, so you only edit .env variables (see .env.tpl) or you can backup other dockerized SQL instance. See below.

# Installation
Create directory for dumps, defined in .env by 'DUMP_PATH'

## Backup non-docker SQL instance
Just copy .env.tpl to .env and set required variables (mysql root password, hostname if it is not 127.0.0.1)

## Backup dockerized SQL instance (other dockerized project)
You can expose SQL server port (3306) from external networks and than you can contiue as you are running non-dockerized SQL backup (see above)  
or  
You need to setup shared network that is running SQL database. Mysqlbackup docker instance will connect to this network and than SQL server is available without exposing its port (more secure way). You can also use (symlink) your existing .env so for example SQL root password is defined only once.

### Dockerized SQL server part
In your dockerized project you need to define ```MYSQL_DOCKER_NETWORK=somenename``` in your ```.env``` and modify ```docker-compose.yml``` so that SQL server instance and all services accessing SQL are in the same network. You can observe test/docker-compose.yml how to define network and access it from services (see yaml section "networks" in services section and in top level section). You don't need to modify lines from the example, just use it in your docker-compose.yml.  
You can also set MYSQLBACKUP_CRON_TIME to set non-default backup time.  
After restart (docker compose down/up) your project should be ready for backup using this mysqlbackup project.

### MYSQLBACKUP setup
When you have your project ready, you can setup your backup. You need to copy docker-compose.override.yml.tpl to docker-compose.override.yml so you can connect to external SQL server network.
To define required variables you can simply create your ```.env``` where you define the same MYSQL_DOCKER_NETWORK and MYSQL_PASSWORD variable, setup MYSQL_HOST to the service name your project is using or you can symlink your existing project .env (so password and docker network is defined only once) and you can redefine variable differences by in docker-compose.override.yml (see file for examples).
