#!/bin/bash
docker-compose up -d
docker-compose exec apachebench ab -r -n 20000 -c 6000 nginx/
docker-compose down