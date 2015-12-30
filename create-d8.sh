#!/bin/bash
# Creates a docker container for Drupal 8 and MySql
MYSQL_ROOT_PASSWORD="cleveland"
MYSQL_DATABASE="d8"
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
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
END='\e[0m'
FIREFOX="/Applications/Firefox.app/Contents/MacOS/firefox"

function firefox {
	if [ -f FIREFOX ];then
		open -a /Applications/Firefox.app/Contents/MacOS/firefox -g $1
	else
		#Open on my box
		open -a /Applications/Firefox\ ESR.app/Contents/MacOS/firefox -g $1
	fi
}

echo ""
echo "*"
echo "* Auto creating docker containers for Drupal 8 and MySQL"
echo "*"
echo ""
#Check REQUIREMENTS
printf "${GREEN}Checking Requirements${END}\n"
#Make sure docker is installed
if which docker >/dev/null; then
    echo "docker is installed"
else
    echo "docker does not exist"
    echo "Please install Docker Toolbox"
    printf "Goto: ${YELLOW} https://www.docker.com/docker-toolbox ${END}\n"
    firefox https://www.docker.com/docker-toolbox
    exit
fi

#Make sure docker-machine is installed
if which docker-machine >/dev/null; then
    echo "docker-machine is installed"
else
    echo "docker-machine does not exist"
    echo "Please install Docker Toolbox"
    printf "Goto: ${YELLOW}https://www.docker.com/docker-toolbox${END}\n"
    firefox https://www.docker.com/docker-toolbox
    exit
fi

#Make sure we are on Mac for now
if [[ $OS == 'Darwin' ]]; then
   echo "Mac OS - Darwin detected"
else
	echo "Currently this script only supports Mac OS"
	echo "Run on a Mac or modify this script to work with Linux"
	exit
fi
#Check Docker VM
printf "\n${GREEN}Checking Docker VM status${END}\n"
#Is a docker vm up and running?
VM_RUNNING="$(docker-machine ls |grep Running |wc -l)"
if [ $VM_RUNNING = 0 ]; then
	echo "Docker VM is not Running"
	echo "Please start a Docker VM"
	printf "Example: ${YELLOW}docker-machine start docker-vm${END}\n"
	echo "To view available VM's:"
	printf "Type: ${YELLOW}docker-machine ls${END}\n"
	docker-machine ls
	exit
fi

DOCKER_VM="$(docker-machine ls |grep Running |awk '{print $1}')"
HOST_IP="$(docker-machine ip $DOCKER_VM)"
printf "A Docker VM named ${YELLOW}$DOCKER_VM${END} is running and assigned an IP of ${YELLOW}$HOST_IP${END}\n"
echo "Loading ENV for $DOCKER_VM"
eval "$(docker-machine env $DOCKER_VM)"
echo '# Run this command to configure your shell:' 
printf '# eval "$(docker-machine env %s)"\n' "$DOCKER_VM"
echo '# After running the eval command you will be able to execute docker commands from the command prompt.' 
#Check status of Drupal 8
echo ""
printf "Checking status of Drupal 8 container named ${YELLOW}$DRUPAL_CONTAINER${END}\n"
#exit
#set
#docker-machine env $DOCKER_VM
echo "Kill and Remove existing containters"
docker kill $DRUPAL_CONTAINER
docker rm $DRUPAL_CONTAINER
docker kill $MYSQL_CONTAINER
docker rm $MYSQL_CONTAINER
echo ""
echo "Starting Drupal 8 container on $DOCKER_VM"
docker run --name $DRUPAL_CONTAINER -p $HOST_PORT:80 -d drupal:$DRUPAL_VERSION
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
echo "Database name: $MYSQL_DATABASE"
echo "Database username: $MYSQL_USER"
echo "Database password: $MYSQL_PASSWORD"
echo "MySQL Host: $HOST_IP"
echo "MySQL Port: $MYSQL_HOST_PORT"
echo "  Note: If username above fails, use root and password below for Drupal 8 setup."
echo "Addtional info... root password: $MYSQL_ROOT_PASSWORD"
echo ""
echo "Container $DRUPAL_CONTAINER is running Drupal version $DRUPAL_VERSION"
echo "Container $MYSQL_CONTAINER is running MySQL version $MYSQL_VERSION"
echo ""

firefox http://$HOST_IP:$HOST_PORT
