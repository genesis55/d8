#!/bin/bash
# Creates a docker container for Drupal 8 and MySql

#Make sure docker is installed
if which docker >/dev/null; then
    echo "docker is installed"
else
    echo "docker does not exist"
    echo "Please install Docker Toolbox"
    echo "Goto: https://www.docker.com/docker-toolbox"
    echo ""
    open -a /Applications/Firefox\ ESR.app/Contents/MacOS/firefox -g https://www.docker.com/docker-toolbox
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

#Is a docker vm up and running?
VM_RUNNING="$(docker-machine ls |grep Running |wc -l)"
echo $VM_RUNNING