version: "3"

services:
  mysqlbackup:
    networks:
      - database-network

networks:
    database-network:
      name: $MYSQL_DOCKER_NETWORK
      external: true
