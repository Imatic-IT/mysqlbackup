version: "3"

services:
  mysqlbackup:
    environment:
      MYSQL_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_HOST: db
    networks:
      - database-network

networks:
    database-network:
      name: $MYSQL_DOCKER_NETWORK
      external: true
