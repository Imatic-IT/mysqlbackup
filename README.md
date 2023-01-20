# mysqlbackup
Image for regular MySQL / MariaDB backup

# TODO 
* [X] ~~*1) dockerfile - debian:bullseye-slim based - mariadb client, cron, dumb-init*~~ [2023-01-20]
  * [X] ~~*1.1) use env variable for cron time to set automatic dump*~~ [2023-01-20]
  * [X] ~~*1.2) entrypoint - write crontab at start of container*~~ [2023-01-20]
  * [X] ~~*1.3) use env variable mysql user and password*~~ [2023-01-20]
* [X] ~~*2) docker compose*~~ [2023-01-20]
* [X] ~~*3) rewrite mysql-backup.sh to use env variables, remove config file section*~~ [2023-01-20]
* [ ] 4) dump script - log to file