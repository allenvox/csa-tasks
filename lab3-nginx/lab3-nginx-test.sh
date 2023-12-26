#!/bin/bash
echo [@] creating docker network net1
docker network create net1
echo [@] executing nginx container on port 8080
docker run -it --name nginx -d -p 8080:80 nginx
sleep 1
echo [@] executing httpd container
docker run -it --name httpd -d httpd
sleep 1
echo [@] connecting nginx & httpd containers to net1
docker network connect net1 nginx
docker network connect net1 httpd
echo [@] performing Apache Benchmark for nginx from httpd
docker exec -it httpd ab -r -n 30000 -c 7000 nginx/
