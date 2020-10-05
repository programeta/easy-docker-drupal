#!/bin/bash

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
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=local.vm"
