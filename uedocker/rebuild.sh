#!/bin/bash
#
# Builds any updates and starts with the existing database data (presumes it exists - use recreate to make a new DB)
#

docker-compose build && \
docker-compose down && \
docker-compose up -d
