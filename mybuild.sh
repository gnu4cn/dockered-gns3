#!/bin/sh
echo 'DOCKER_OPTS="--dns 223.5.5.5 --dns 223.6.6.6"' >> /etc/default/docker
docker build -t="unisko/gns3-dockered" .
