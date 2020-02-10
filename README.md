# What contains this README file
This file contain next sections:
* **[Containers definition](#containers-definition)** -> Explain all containers that have been used to work in your local environment
* **[First steps](#first-steps)** -> Explain how to change the downloaded project to the final Git repository and how deploy your first
version of Drupal
* **[Debug your code](#debug-your-code)** -> Explain how to configure the environment and your IDE to debug your code remotely
* **[Which have this repository](#which-have-this-repository)** -> Explain the files on this repository
* **[Generate id_rsa and id_rsa.pub](#generate-id_rsa-and-id_rsapub)** -> Steps to generate keygen files
* **[Generate dummy certificate for SSL](#generate-dummy-certificate-for-ssl)** -> Steps to generate SSL certificate
* **[Git user initialize](#git-user-initialize)** -> Initialize Git user in `php` container

# Containers definition:
This local environment have some containers (services) that allows developers to work with one or more drupal instances.

## Service "mariadb"
Contain environment to load a mariadb database, which have the database stored in a persistent volume /var/lib/mysql.
It has internally opened the 3306 port in order to be available for the rest of containers as "mariadb" host. Optionally you
can connect from your Windows machine through port 3306 with credentials defined in the `.env` file.

### Starting a existing Database
See https://hub.docker.com/_/mariadb for more detailed information

## Service "php"
This container is the most important, it has an already configured Apache Server and PHP 7.3 working as a "module" not as "PHP-FPM".

See https://hub.docker.com/_/drupal for more detailed information

### Available ports
By default this container exposes to the host two ports:
* 80    -> Apache HTTP request
* 443   -> Apache HTTPS request

You must set your certtificate replacing the files that exists in `conf/apache/ssl`. If you do not need SSL certificate review
the `conf/php/virtualhost.conf` to remove the VirtualHost for SSL and remove in the VirtualHost:80 the redirection to SSL

### Where is drupal stored
Drupal will be stored in the `html` folder, here you must deploy yor project and configure it in the VirtualHost setting with the correct
DocumentRoot path

### Modifying the default php.ini values
If it is necessary, you can change the default php.ini values, to do that you need to modify the file `conf/php/php.ini` and modify all
necessary variables. By default some changes have been implemented to make easier the development:
* Max execution time -> Increased from 30 to 60 seconds
* Memory limit -> Increased from 128M to 256M
* Max upload files -> Increased from 2M to 32M (here you must change the `post_max_size` and `upload_max_filesize` variables)

If you need to enable the XDebug, you need to uncomment the lines that are commented in the php.ini file

### Accessing into container
To access into a container once the docker-compose is executed, you must launch the sentence:
```
docker-compose exec -u docker php bash
```

### Default PHP version and how to change
By default this container runs with PHP 7.3, in case that you need downgrade this version you need to change it in the `Dockerfile-drupal` file, the
first line:
```
FROM drupal:8-apache
```
To this other:
```
FROM drupal:7-apache
```
Once this lines have been changed you need to rebuild the project in order to take effect of the changes.
```
docker-compose up -d --build
```

### Gettings variables in PHP exposed by docker-compose
When a variable is exposed in the docker-compose.yml file you need to retrieve the information like this example:
```
  $databases['default']['default'] = array (
    'database' => getenv('MYSQL_DATABASE'),
    'username' => getenv('MYSQL_DATABASE_USER'),
    'password' => getenv('MYSQL_DATABASE_PASS'),
    'host' => getenv('MYSQL_DATABASE_HOST'),
    'port' => getenv('MYSQL_DATABASE_PORT'),
    'driver' => 'mysql'
  );
```



## Service "mailhog"
This service allows the user to send *dummy* emails to log all of them and see the final results.

You must connect your Drupal instance using SMTP and mimemail modules with next parameters:
* Go to the SMTP administration page: /admin/config/system/smtp and set this variables
  * SMTP: mailhog
  * Port: 1025
* Go to the MimeMail page: /admin/config/system/mimemail and set this variables
  * Formatter: Mime Mail Mailer
  * Sender: SMTP Mailer

With this information your system is available to *emulate* sending emails (in HTML format) and the results can be shown at http://localhost:8025

### Available ports
By default this container exposes to the host one port:
* 8025 -> Mailhog

## Service "redis"
This service is a cache for Drupal. You will need to install the module `redis` (all dependencies are built in the container).
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
This service allows indexing all content using Apache Solr. You will need to install the module `Search API Solr`.

By default this service creates a Solr core called `drupalsolr`.

You need to follow the detailed instructions in the README.md file downloaded in the module `search_apoi_solr` to configure
properly the connection.

### Available ports
By defailt this container exposes to the host one port:
* 8983 -> Apache Solr request


# FIRST STEPS:
* Once you had configured the previous steps you only need this actions:

  * Initialize docker
```
docker-compose up -d --build
```
  * Go into PHP container (as root)
```
docker-compose exec php bash
```

Additionally this container have another user to work with no root privileges, just adding `-u docker`:
```
docker-compose exec -u docker php bash
```


Your system is ready to work with drupal. ENJOY!!

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


# What do we have on this repository
This repository contains files and folders to start quickly to deploy a new drupal instance:

* `.env` file -> Contains variable definitions to connect to Drupal, project name, ... You can add all the variables that you need to configure on
your environment. Please take into account that if you want to see all these variables in your container you must add this in `docker-compose.yml` file
* `docker-compose.yml` file -> Contain the definition of all containers needed to work in your local environment
* `conf` folder -> Have some configurations, mainly PHP and VirtualHost configurations
* `html` folder -> Folder to store your projects.
* `Dockerfile-drupal` file -> Contains all the needed configuration for PHP container to establish the envirnoment to work with Drupal
(PHP Modules, applications such us `vim`, SSH Server, ...). This image have been extended from a Docker image [Drupal 8](https://hub.docker.com/_/drupal/). Please referer to Docker image to see all available options.
* `README.md` file -> This file


# Generate id_rsa and id_rsa.pub
This step explain how to generate the files id_rsa and id_rsa.pub based on linux.

You must launch in your host the next sentence:
```
ssh-keygen -f conf/php/ssh/id_rsa -N ""
```
This files can be used to connect automatically with any Git account without password, you must add the SSH-KEY `conf/php/ssh/id_rsa.pub` in
the repository to avoid the prompt asking for the user and password ...

In case that you are working on linux, you can copy your id_rsa and id_rsa.pub from your .ssh folder
```
cp ~/.ssh/id_rsa conf/php/ssh/id_rsa
cp ~/.ssh/id_rsa.pub conf/php/ssh/id_rsa.pub
```

# Generate dummy certificate for SSL
We assume that you are located in the docroot of this document to launch this sentence:
```
openssl req -x509 -nodes -days 2048 -newkey rsa:2048 -keyout conf/apache/ssl/localhost.key -out conf/apache/ssl/localhost.crt
```
NOTE: This step is not necessary if you are using the image "programeta/drupal-php". This image have already a dummy SSL certificate



# Git user initialize
If you need use Git inside container, you must fill the file `conf/php/git_user_initialize.sh`

This file must be launched every time that the container `php` is created to stablish the proper values to connect with Git. With this
option you will be avoid the error message when you prepare a commit.
