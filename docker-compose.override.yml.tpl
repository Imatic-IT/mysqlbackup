version: "3"

services:
  mysqlbackup:
    environment:
      # Set MYSQL_PASSWORD variable from other variable defined in .env when symlinking from existing project
      #MYSQL_PASSWORD: ${DB_ROOT_PASSWORD}
      # Set MYSQL_HOST to service name from other project
      #MYSQL_HOST: db
    networks:
      - database-network

networks:
    database-network:
      name: $MYSQL_DOCKER_NETWORK
      external: true
