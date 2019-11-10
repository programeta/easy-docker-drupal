# What contains this README file
This file contain next sections:
* **[Containers definition](#containers-definition)** -> Explain all containers that have been used to work in your local environment
* **[First steps](#first-steps)** -> Explain how to change the downloaded project to the final Git repository and how deploy your first
version of Drupal
* **[Debug your code](#debug-your-code)** -> Explain how configure the environment and your IDE to debug your code remotely
* **[Which have this repository](#which-have-this-repository)** -> Explain the files in this repository
* **[Generate id_rsa and id_rsa.pub](#generate-id_rsa-and-id_rsa.pub)** -> Steps to generate keygen files
* **[Generate dummy certificate for SSL](#generate-dummy-certificate-for-ssl)** -> Steps to generate SSL certificate


# Containers definition:
This local environment have some containers (services) that allow developers work with one or more drupal instances.

## Service "mariadb"
Contain environment to load a mariadb database, which have the database stored in a persistent volume /var/lib/mysql.
Internally have open the port 3306 to be available connected for rest of containers as "mariadb" host

### Starting a existing Database
See https://hub.docker.com/_/mariadb for more detailed information

## Service "php"
This container is the most important that have configured an Apache Server and PHP 7.3 working as "module" not as "PHP-FPM".

See https://hub.docker.com/_/drupal for more detailed information

### Available ports
By defailt this container expose to host two ports:
* 80    -> Apache HTTP request
* 443   -> Apache HTTPS request

You must set your certtificate replacing the files that exists in `conf/apache/ssl`. If you do not need SSL certificate review
the `conf/php/virtualhost.conf` to remove the VirtualHost for SSL and remove in the VirtualHost:80 the redirection to SSL

### Where drupal is stored
Drupal will be stored in `html` folder, here you must deploy yor project and configure it in the VirtualHost setting the correct DocumentRoot path

### Modifiyng the default php.ini values
You are able to change the default php.ini values, to do that you need to modify the file `conf/php/php.ini` and modify all
necessary variables. By default some changes have been implemented to make easy the development:
* Max execution time -> Increased from 30 to 60 seconds
* Memory limit -> Increased from 128M to 256M
* Max upload files -> Increased from 2M to 32M (here you must change the `post_max_size` and `upload_max_filesize` variables)

If you need enable the XDebug, you need uncomment the lines commented in the php.ini file

## Service "mailhog"
This service allow send *dummy* emails to log all of them and see the final results.

You must connect your Drupal instance using SMTP and mimemail modules with next parameters:
* Go to the SMTP administration page: /admin/config/system/smtp and set this variables
  * SMTP: mailhog
  * Port: 1025
* Go to the MimeMail page: /admin/config/system/mimemail and set this variables
  * Formatter: Mime Mail Mailer
  * Sender: SMTP Mailer

With this information your system is available to *emulate* to send emails (in HTML format) and the results you can see in http://localhost:8025

### Available ports
By defailt this container expose to host one port:
* 8025 -> Mailhog

## Service "redis"
This service is a cache for Drupal. You will need install the module `redis` (all dependencies are built in the container).
* Installing using composer -> `composer require drupal/redis`
* Enable the module -> `drush en redis`

Once the module is enabled, you can add the next information in your `settings.php` file:
```
$settings['redis.connection']['interface'] = 'Predis'; // Can be "Predis".
$settings['redis.connection']['host']      = 'redis';  // Your Redis instance hostname.
$settings['redis.connection']['port']      = '6379';  // Redis port
$settings['cache']['default'] = 'cache.backend.redis';
```

The system automatically connect with Redis. You can see in `Status report` if the module works properly.

## Service "solr"
This service allows index all content using Apache Solr. You will need install the module `Search API Solr`.

By default this service create a core called `drupalsolr`.

You need follow the instructions detailed in the README.md file downloaded in the module `search_apoi_solr` to configure
properly the connection.

### Available ports
By defailt this container expose to host one port:
* 8983 -> Apache Solr request


# FIRST STEPS:
* Once you had configured the previous steps you only need this actions:

  * Initialize docker
```
docker-compose up -d --build
```
  * Go into PHP container
```
docker-compose exec php bash
```

Your system is ready to work with new drupal. ENJOY!!

# DEBUG your code:
This section is explained to work with Visual Studio Code...
* Go to: conf/php/php.ini and uncomment the last lines in the file (recreate the docker images to enable it)
* Install all extensions for Drupal 8 or 7 in your VSC editor: https://www.drupal.org/docs/develop/development-tools/configuring-visual-studio-code
* Install Extension in your navigator:
  * Firefox: https://addons.mozilla.org/en-GB/firefox/addon/xdebug-helper-for-firefox/
  * Chrome: https://chrome.google.com/extensions/detail/eadndfjplgieldjbigjakmdgkmoaaaoc
* Enable the debug in the navigator
* Configure launch.json (CTRL+SHIFT+D -> Add Configuration) and replace all content with this lines:
```
        {
            // Use IntelliSense to learn about possible attributes.
            // Hover to view descriptions of existing attributes.
            // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
            "version": "0.2.0",
            "configurations": [
                {
                    "name": "Listen PHP Code",
                    "type": "php",
                    "request": "launch",
                    "port": 9000,
                    "stopOnEntry": true,
                    "pathMappings": {
                        "/var/www/html/": "${workspaceRoot}/drupal_dandy/",
                    }
                },
                {
                    "type": "chrome",
                    "request": "launch",
                    "name": "Listen JavaScript Code",
                    "url": "http://localhost",
                    "webRoot": "${workspaceFolder}/drupal_dandy/web"
                }
            ]
        }
```
* Once your definition is finished you can go to the "Debug" section pressing `F5` and select the option that you want to debug (PHP or JavaScript)


# Which have this repository
This repository contains files and folders to start quickly to deploy a new drupal instance:

* `.env` file -> Contains vairables definitions to connect to Drupal, project name, ... You can add all variables that you need to configure
your environment. Please take account that if you want see all these variables in your container you must add this in `docker-compose.yml` file
* `docker-compose.yml` file -> Contain the definition of all containers needed to work in your local environment
* `conf` folder -> Have some configurations, mainly PHP and VirtualHost configurations
* `html` folder -> Folder to store your projects.
* `Dockerfile-drupal` file -> Contain all needed configuration for PHP container to establish the envirnoment to work with Drupal
(PHP Modules, applications such us `vim`, SSH Server, ...). This image have been extended from a Docker image [Drupal 8](https://hub.docker.com/_/drupal/). Please referer to Docker image to see all available options.
* `README.md` file -> This file


# Generate id_rsa and id_rsa.pub
This step explain how to generate the files id_rsa and id_rsa.pub based on linux.

You must launch in your host the next sentence:
```
ssh-keygen
```
And press enter to respond all questions. Once the process has finished you must copy the files ~\.ssh\id_rsa and ~\.ssh\id_rsa.pub
in the directory `conf/php/ssh` and replace the files.


# Generate dummy certificate for SSL
We assume that you are located in the docroot of this document to launch this sentence:
```
openssl req -x509 -nodes -days 2048 -newkey rsa:2048 -keyout conf/apache/localhost.key -out conf/apache/localhost.crt
```
