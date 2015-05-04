#!/bin/sh
echo 'DOCKER_OPTS="--dns 192.168.20.6 --dns 221.6.4.66"' >> /etc/default/docker
docker build -t="unisko/gns3-dockered" .
