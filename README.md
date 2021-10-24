# Easy Docker Drupal (EDD)

EDD is a tool based on docker to help drupal developers to generate easily the neccessary structure to allocate their Drupal projects.

This README.md contains:

* **[Starting with EDD](#starting-edd)** Starting with EDD
* **[Containers maintenance](#containers-maintenance)** Containers maintenance
* **[Tips to perform functionality](#tips)** Tips to perform functionality

## Starting with EDD

Once EDD is downloaded you need initialize the environment with

```bash
bash scripts/initialize.sh
```

This sentence ask some questions to create a basic structure based on your preferences:

* Machine name: this is a prefix added for containers to this project
* Database storage: MariaDB or Postgres
* Web server engine: Apache or Nginx
* Search engine: Solr or Elastic
* Mailhog: Enable or disable this container
* Redis: Enable or disable this container
* Launch docker: Launch automatically sentences to generate enviornment with selected values

This script will prepare your environment to run your first application preparing:

* URL Domain: "https://&lt;Machine name&gt;.vm/"
* DocumentRoot:

You will need modify your host file (/etc/hosts or c:\windows\system32\drivers\etc\host) to tell your SO where is located your new project, for example:

```text
127.0.0.1 <Machine name>.vm
```

## Containers maintenance

You can easily manage all containers configuring and adapting their inside applications:

* **[Apache container](#apache-container)** Apache container
* **[Nginx container](#nginx-container)** Nginx container
* **[PHP container](#php-container)** PHP container (for nginx configuration)
* **[MySQL container](#mysql-container)** MySQL container
* **[Postgres container](#postgres-container)** Postgres container
* **[Solr container](#solr-container)** Solr container
* **[Elastic search container](#elastic-container)** Elastic search container
* **[Mailhog container](#mailhog-container)** Mailhog container
* **[Redis container](#redis-container)** Redis container

### Apache container

This container is based on https://hub.docker.com/_/drupal using by default `drupal:9-apache` image.

Extend configuration adding some tools such us:

* Create new "docker" user, to avoid use of root in develop environment
* Add tools `composer`, `drush launcher`, `drush extensions`, `drupal console`
* Add dummy certificate to support HTTPS
* Disable OPCache
* MariaDB client and Postgres client

This container expose 80 and 443 ports. All traffic is redirected to 443 port. "https://&lt;Machine name&gt;.vm/"

#### Configuration files

Exists several files where you can adapt/manage the configuration for this container:

* VirtualHost management: located in `conf/apache/virtualhost.conf`. You can add/modify several virtualhost as you need.
* PHP Configuration: located in `conf/php/php.ini`. You can adapt PHP configuration adding whatever PHP config parameters

Once this files are modified, you'll need restart the apache container

```bash
docker-compose restart apache
```

### Nginx container

This container is based on https://hub.docker.com/_/nginx using by default `nginx:1-alpine` image.

This container expose 80 and 443 ports. All traffic is redirected to 443 port.

#### Configuration files

Exists several files where you can adapt/manage the configuration for this container:

* Servers management: located in `conf/nginx/nginx.d/default.conf`. You can add/modify several servers as you need.

Once this file is modified, you'll need restart the nginx container

```bash
docker-compose restart nginx
```

### PHP container

This container is based on https://hub.docker.com/_/php using by default `php:8-fpm` image.

Extend configuration adding some tools such us:

* Add tools `composer`, `drush launcher`, `drush extensions`, `drupal console`
* Add dummy certificate to support HTTPS
* Disable OPCache
* MariaDB client and Postgres client
* Extend use of GD images to manage: jpeg, png and webp

#### Configuration files

Exists several files where you can adapt/manage the configuration for this container:

* PHP Configuration: located in `conf/php/php.ini`. You can adapt PHP configuration adding whatever PHP config parameters

Once this file is modified, you'll need restart the php container

```bash
docker-compose restart php
```

### MySQL container

This container is based on https://hub.docker.com/_/mariadb using by default `mariadb:10.5` image.

Please follow instructions in https://hub.docker.com/_/mariadb to manage environment variables if needed.

By default we set `root` password as `root`.

This container expose 3306 port.

### Postgres container

This container is based on https://hub.docker.com/_/postgres using by default `postgres:12` image.

Please follow instructions in https://hub.docker.com/_/postgres to manage environment variables if needed.

By default we set password as `root`.

This container expose 5432 port.

### Solr container

This container is based on https://hub.docker.com/_/solr using by default `solr:8` image.

This container expose 8983 port. "http://&lt;Machine name&gt;.vm:8983"

### Elastic search container

This container is based on https://hub.docker.com/_/elasticsearch using by default `elasticsearch:7.10.1` image.

This container expose 9200 and 9300 ports.

### Mailhog container

This container is based on https://hub.docker.com/r/mailhog/mailhog/ using by default `mailhog/mailhog` image.

This container expose 8025 port. "http://&lt;Machine name&gt;.vm:8025"


### Redis container

This container is based on https://hub.docker.com/_/redis using by default `redis:5-alpine` image.

## Tips to perform functionality

In this part we will see hoy to enable some tools that containers offer by default and debugging.

* **[Use of environment variables in your project](#environment-variables)** Use of environment variables in your project
* **[Debug your code with Visual Studio Code](#debugging)** Debug your code with Visual Studio Code

### Use of environment variables in your project

By default, all containers have availability to retrieve several variables from a global file called `.env` that you can find in this folder.

This allow to you send information to containers, and is recommended their use to work with best practices in abstraction application.

For example, to isolate your settings configuration from the infrastructure you can modify your database connection in your drupal settings.php file:

```text
  $databases['default']['default'] = array (
    'database' => getenv('MYSQL_DATABASE'),
    'username' => getenv('MYSQL_DATABASE_USER'),
    'password' => getenv('MYSQL_DATABASE_PASS'),
    'host' => getenv('MYSQL_DATABASE_HOST'),
    'port' => getenv('MYSQL_DATABASE_PORT'),
    'driver' => 'mysql'
  );
```

Or adding, for example, the trusted hosts in environment variables:

```text
  $settings['trusted_host_patterns'] = explode(',', DRUPAL_THUSTED_HOST);
```

IMPORTANT: Once file `.env` is modified you will need restart your containers.

### Debug your code with Visual Studio Code

This section is explained to work with Visual Studio Code...

* Go to: `conf/php/php.ini` and uncomment the last lines in the file (recreate the docker images to enable it)
* Install all extensions for Drupal 8 or 7 in your VSC editor: https://www.drupal.org/docs/develop/development-tools/configuring-visual-studio-code
* Install Extension in your navigator:
  * Firefox: https://addons.mozilla.org/en-GB/firefox/addon/xdebug-helper-for-firefox/
  * Chrome: https://chrome.google.com/extensions/detail/eadndfjplgieldjbigjakmdgkmoaaaoc
* Enable the debug in the navigator
* Configure launch.json (CTRL+SHIFT+D -> Add Configuration) and replace all content with this lines:

```text
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
