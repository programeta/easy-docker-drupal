#!/bin/bash
NC='\033[0m' # No Color
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'

printf '\n'
printf "Please, input the name of the project (as machinename)?:"
read PROJECT_NAME

printf "${GREEN}Configuring environment...${NC}\n"
echo "\nPROJECT_NAME=${PROJECT_NAME}" >> .env

#Generate certificates for environment
FILE=~/.ssh/id_rsa
if [ ! -f "$FILE" ]; then
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""
fi

#Copy certificates from local into environment
cp ~/.ssh/id_rsa conf/php/ssh/id_rsa
cp ~/.ssh/id_rsa.pub conf/php/ssh/id_rsa.pub

#Generate certificate for HTTPS
openssl req -x509 -new -newkey rsa:4096 -nodes -days 2048 \
    -keyout conf/apache/ssl/localhost.key -out conf/apache/ssl/localhost.crt \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=local.vm" > /dev/null 2>&1

printf "\n${GREEN}Environment configured...${NC}\n"
printf "\nNow you can modify the file ${BLUE}'conf/php/virtualhost.conf'${NC} to add any projects as you need."
printf "\nRemember that folder ${BLUE}'html'${NC} is shared in php container in path ${BLUE}'/var/www/html'${NC} to configure properly DocumentRoot in your virtualhost"
printf "\n"

