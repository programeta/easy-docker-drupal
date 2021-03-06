# What contains this README file
This file contain next sections:
* **[First steps](#first-steps)** -> Explain how to change the downloaded project to the final Git repository and how deploy your first
version of Drupal
* **[Containers definition](#containers-definition)** -> Explain all containers that have been used to work in your local environment
* **[Debug your code](#debug-your-code)** -> Explain how configure the environment and your IDE to debug your code remotely
* **[Which have this repository](#which-have-this-repository)** -> Explain the files in this repository
* **[Generate id_rsa and id_rsa.pub](#generate-id_rsa-and-id_rsapub)** -> Steps to generate keygen files
* **[Generate dummy certificate for SSL](#generate-dummy-certificate-for-ssl)** -> Steps to generate SSL certificate
* **[Git user initialize](#git-user-initialize)** -> Initialize Git user in `php` container

# First steps
1.- To prepare your new local environment you only need to initialize the environment using the sentence
```
sh scripts/initialize.sh
```
This script makes a basic configuration in:
  * Who containers are named (this ensure that no collision between projects, one project one easy-docker-drupal)
  * Copy your id_rsa and id_rsa.pub into PHP container to use the same SSH Keys in GitLab or GitHub
  * Generate a dummy SSL Certificate to work under https in this environment
  * Make changes in your VirtualHost where:
    * ServerName will be the name that you entered, for example, mi-first-environment.vm
    * DocumentRoot is established to respond in path '/var/www/html/mi-first-environment/web'

2.- Once initialized the environment you will able to start environment using sentence
```
docker-compose up -d --build
```
3.- Go into PHP container (as root)
```
docker-compose exec php bash
```

Additionally this container have an other user to work with no root privileges, just adding `-u docker`:
```
docker-compose exec -u docker php bash
```

This environment configure a default database called `drupal` with user `root` and password `root`

## Configure your project in Apache
By default the VirtualHost has been configured using the script `initialize.sh`, you can modify
the file "conf/php/virtualhost.conf" if you need some extra configuration to perform your website.
The VirtualHost based in port 80 is used to force a redirection to 443 port, avoiding the use
of insecure pages.
You can add more than one VirtualHost to make this environment multipurpose for more than
one Drupal project.

## Modify your "hosts" file
Is very important that your file "/etc/hosts" or "c:\windows\drivers\etc\hosts" will be modified
to add a resolution for `ServerName` defined in your `VirtualHost` configuration.

# Containers definition:
This local environment have some containers (services) that allow developers work with one or more drupal instances.

## Service "mariadb"
Contain environment to load a mariadb database, which have the database stored in a persistent volume /var/lib/mysql.
Internally have open the port 3306 to be available connected for rest of containers as "mariadb" host. Optionally you
can connect from your Windows machine through port 3306 with credentials defined in `.env` file.

### Starting a existing Database
See https://hub.docker.com/_/mariadb for more detailed information

## Service "php"
This container is the most important that have configured an Apache Server and PHP 7.3 working as "module" not as "PHP-FPM".

See https://hub.docker.com/_/drupal for more detailed information

### Available ports
By defailt this container expose to host two ports:
* 80    -> Apache HTTP request
* 443   -> Apache HTTPS request

By default a dummy certificate is created when you launch the `inicialize.sh` script. All request in port 80 will be
redirected to port 443.
You are able to add more projects by creating the VirtualHost  entry in the file `conf/php/virtualhost.conf`

### Where drupal is stored
Drupal will be stored in `html` folder, here you must deploy your project and configure it in the VirtualHost setting the correct DocumentRoot path

### Modifiyng the default php.ini values
You are able to change the default php.ini values, to do that you need to modify the file `conf/php/php.ini` and modify all
necessary variables. By default some changes have been implemented to make easy the development:
* Max execution time -> Increased from 30 to 60 seconds
* Memory limit -> Increased from 128M to 256M
* Max upload files -> Increased from 2M to 32M (here you must change the `post_max_size` and `upload_max_filesize` variables)

If you need enable the XDebug, you need uncomment the lines commented in the php.ini file

### Support git autocompletion
This version support git autocompletion

### Accessing into container
To access into container, once the docker-compose is executed, you must launch the sentence:
```
docker-compose exec -u docker php bash
```

### Default PHP version and how to change
By default this container runs with PHP 7.4, in case that you need downgrade this version you need change in the `Dockerfile-drupal` the
first line:
```
FROM drupal:9-apache
```
For this other:
```
FROM drupal:7-apache
```
Once this lines have been changed you need rebuild the project to take effect the changes.
```
docker-compose up -d --build
```

### Gettings variables in PHP exposed by docker-compose
When a variable is exposed in the docker-compose.yml file you nedd retrieve her information like this example:
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
$settings['redis.connection']['interface'] = 'PhpRedis'; // Can be "Predis".
$settings['redis.connection']['host']      = 'redis';  // Your Redis instance hostname.
$settings['cache']['default'] = 'cache.backend.redis';
```
The PHP container (or service) is configured with all libraries to use PHPRedis.

The system automatically connect with Redis. You can see in `Status report` if the module works properly.

## Service "solr"
This service allows index all content using Apache Solr. You will need install the module `Search API Solr`.

By default this service create a core called `drupalsolr`.

You need follow the instructions detailed in the README.md file downloaded in the module `search_apoi_solr` to configure
properly the connection.

### Available ports
By defailt this container expose to host one port:
* 8983 -> Apache Solr request

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
ssh-keygen -f conf/php/ssh/id_rsa -N ""
```
This files could be used to connect automatically with any Git without password, you must add the SSH-KEY `conf/php/ssh/id_rsa.pub` in
the repository to avoid question for user and password...

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
