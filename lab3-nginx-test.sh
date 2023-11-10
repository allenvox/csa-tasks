#!/bin/bash
echo [@] executing nginx container on port 8080
docker run -it -d -p 8080:80 nginx
echo [@] waiting 2 seconds for nginx to start
sleep 2
echo [@] performing Apache Benchmark for localhost:8080
ab -n 10000 http://localhost:8080/
