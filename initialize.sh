#!/bin/bash
NC='\033[0m' # No Color
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'

printf '\n'
printf "Please, input the name of the project (as machinename): "
read PROJECT_NAME

printf "${GREEN}Configuring environment...${NC}\n"
printf "  Modifying environment name...${NC}\n"
sed -i "s/PROJECT_NAME=vm/PROJECT_NAME=${PROJECT_NAME}/g" .env

#Generate certificates for environment
FILE=~/.ssh/id_rsa
if [ ! -f "$FILE" ]; then
    printf "  Generating SSH keys...${NC}\n"
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""
fi

#Copy certificates from local into environment
printf "  Copying SSH keys...${NC}\n"
cp ~/.ssh/id_rsa conf/php/ssh/id_rsa
cp ~/.ssh/id_rsa.pub conf/php/ssh/id_rsa.pub

#Generate certificate for HTTPS
printf "  Generating SSL certificate for apache...${NC}\n"
openssl req -x509 -new -newkey rsa:4096 -nodes -days 2048 \
    -keyout conf/apache/ssl/localhost.key -out conf/apache/ssl/localhost.crt \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=local.vm" > /dev/null 2>&1

#Configure VirtualHost
printf "  Modifying Virtualhost...${NC}\n"
sed -i "s/your.domain/${PROJECT_NAME}.vm/g" conf/php/virtualhost.conf
sed -i "s/your.docroot.project/${PROJECT_NAME}/g" conf/php/virtualhost.conf


printf "${GREEN}Environment configured...${NC}\n"
printf "  Virtualhost configuration...\n"
printf "   * Domain configured as ${PURPLE}https://${PROJECT_NAME}.vm${NC}\n"
printf "   * Document root configured in ${PURPLE}/var/www/html/${PROJECT_NAME}/web${NC}\n"
printf "\n"
