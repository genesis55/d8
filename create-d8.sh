#!/bin/bash
# Creates a docker container for Drupal 8 and MySql
MYSQL_ROOT_PASSWORD="cleveland"
MYSQL_USER="d8"
MYSQL_PASSWORD="password"
MYSQL_VERSION="5.7.10"
DRUPAL_VERSION="latest"

OS=`uname`
MYSQL_HOST_PORT="3307"
HOST_IP=""
HOST_PORT="8080"

#docker
DRUPAL_CONTAINER="d8"
MYSQL_CONTAINER="ms8"

#Color codes
YELLOW="\e[1;33m"
END='\e[0m'
FIREFOX="/Applications/Firefox.app/Contents/MacOS/firefox"
if [ -f $FIREFOX ];then
   echo "File $FILE exists."
else
	FIREFOX="/Applications/Firefox\ ESR.app/Contents/MacOS/firefox"
fi
echo ""
echo "Auto creating docker containers for Drupal 8 and MySQL"
echo ""
#Make sure docker is installed
if which docker >/dev/null; then
    echo "docker is installed"
else
    echo "docker does not exist"
    echo "Please install Docker Toolbox"
    echo "Goto: ${WHITEBOLD} https://www.docker.com/docker-toolbox $WHITE"
    echo ""
    open -a $FIRFOX -g https://www.docker.com/docker-toolbox
    exit
fi

#Make sure docker-machine is installed
if which docker-machine >/dev/null; then
    echo "docker-machine is installed"
else
    echo "docker does not exist"
    echo "Please install Docker Toolbox"
    echo "Goto: https://www.docker.com/docker-toolbox"
    echo ""
    open -a /Applications/Firefox\ ESR.app/Contents/MacOS/firefox -g https://www.docker.com/docker-toolbox
    exit
fi

#Make sure we are on Mac for now
if [[ $OS == 'Darwin' ]]; then
   echo "Mac OS - Darwin detected"
else
	echo "Currently this script only supports Mac OS"
	echo "Run on a Mac or modify to work with Linux"
	exit
fi
#Is a docker vm up and running?
VM_RUNNING="$(docker-machine ls |grep Running |wc -l)"
if [ $VM_RUNNING = 0 ]; then
	echo "Docker VM is not Running"
	echo "Please start a Docker VM"
	printf "Example: ${YELLOW}docker-machine start docker-vm${END}\n"
	echo "To view available VM's:"
	printf "Type: ${YELLOW}docker-machine ls${END}\n"
fi

DOCKER_VM="$(docker-machine ls |grep Running |awk '{print $1}')"
HOST_IP="$(docker-machine ip $DOCKER_VM)"
echo ""
echo "Loading ENV for $DOCKER_VM"
eval "$(docker-machine env $DOCKER_VM)"
echo ""
#set
#docker-machine env $DOCKER_VM
echo "Kill and Remove existing containters"
docker kill $DRUPAL_CONTAINER
docker rm $DRUPAL_CONTAINER
docker kill $MYSQL_CONTAINER
docker rm $MYSQL_CONTAINER
echo ""
echo "Starting Drupal 8 container on $DOCKER_VM"
docker run --name d8 -p $HOST_PORT:80 -d drupal:$DRUPAL_VERSION
docker run --name $MYSQL_CONTAINER -p $MYSQL_HOST_PORT:3306 -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD -e MYSQL_USER=$MYSQL_USER -e MYSQL_PASSWORD=$MYSQL_PASSWORD -e MYSQL_DATABASE=$MYSQL_DATABASE -d mysql:$MYSQL_VERSION
docker ps
echo ""
echo "Docker Containers are now up and running."
echo ""
echo "Use the following information to setup Drupal 8 for the first time:"
echo ""
echo "HOST Information:"
echo "HOST IP: $HOST_IP"
echo "DRUPAL 8 URL: http://$HOST_IP:$HOST_PORT"
echo ""
echo "MySQL Information:"
echo "MYSQL User: $MYSQL_USER"
echo "MYSQL Password: $MYSQL_PASSWORD"
echo "MYSQL Host Port: $MYSQL_HOST_PORT"
echo "Addtional info... root password: $MYSQL_ROOT_PASSWORD"
echo ""
echo "Container $DRUPAL_CONTAINER is running Drupal version $DRUPAL_VERSION"
echo "Container $MYSQL_CONTAINER is running MySQL version $MYSQL_VERSION"
echo ""

open -a /Applications/Firefox\ ESR.app/Contents/MacOS/firefox -g http://$HOST_IP:$HOST_PORT
