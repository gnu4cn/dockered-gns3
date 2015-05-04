#!/bin/bash
containerID=`sudo docker ps -l -q`
containerHOSTNAME=`sudo docker inspect --format='{{ .Config.Hostname }}' $containerID`
xhost +local:$containerHOSTNAME
