# ns8-webserver

This module use nginx and php-fpm to make a a linux apache mysql (see ns8-mariadb) and php

# update PHP or add new versions

To add new version inside the UI go to ui/src/views/VirtualHosts.vue in the php dropdown. The UI uses the minor version 8.1 but we need to pull the phpfpm container 8.1.30. This is done in imageroot/bin/download-php-fpm, please upgrade from time to time the php version wanted there, the upgrade script imageroot/update-module.d/20restart will pull and restart phpfpm service.

## local database

We use local database to store configuration, you can find it `/home/webserver1/.config/state/databases/vhosts/*.ini`, the TCP port of php-fpm which is unique, is used as an ID, so the first vhost configuration databse will be at 

 `/home/webserver1/.config/state/databases/vhosts/9001.ini`

 Manual customisation can be added to 

### nginx

- add a `dyn-9001.custom` to `/home/webserver1/.config/state/conf.d/`
- `vim /home/webserver1/.config/state/conf.d/dyn-9001.custom` and write a valid nginx configuration
- set the file ownership to webserver1 : `chown webserver1:webserver1 /home/webserver1/.config/state/conf.d/dyn-9001.custom`

### php-fpm

- add `dyn-9001.custom` to  `/home/webserver1/.config/state/php{php version}-fpm-custom.d/` for example `/home/webserver1/.config/state/php7.4-fpm-custom.d/`
- `vim /home/webserver1/.config/state/php7.4-fpm-custom.d/dyn-9001.custom` and write a valid php-fpm configuration
- set the file ownership to webserver1 : `chown webserver1:webserver1 /home/webserver1/.config/state/php7.4-fpm-custom.d/dyn-9001.custom`

#
# Cron in sftpgo container
#

You can use a cron inside the sftpgo container. You must be compatible with a cron format. You can do it by using this command line:
```
runagent -m webserver1
crontab -e
# this is an example to rsync the NethServer repository to the virtualhost 9001
15 */3 * * * podman exec -ti sftpgo rsync --progress -aHS --partial --delete rsync://mirror.nethserver.org/nethserver /srv/sftpgo/data/9001/
```

```
* * * * * command_to_execute
- - - - -
| | | | |
| | | | +---- Day of the week (0 - 7, Sunday is 0 or 7)
| | | +------ Month (1 - 12)
| | +-------- Day of the month (1 - 31)
| +---------- Hour (0 - 23)
+------------ Minute (0 - 59)
```

you can verify the cron by `podman exec -ti sftpgo crontab -l`

## sftpgo : push the website

 Sftpgo is used to upload files to the webserver, once the webserver module is installed the default password and user are admin:admin at http://foo.com/sftpgo/, think to change it

 When you create a virtualhost, a user called by the ID of the virtualhost (its tcp port php-fpm number), the first one is `9001`. A default password is created with the ID of the user, the first one is `9001`, you can modify it inside the web client or admin UI

if you have lost your password you can change it by the command line 

```
# become webserver1 (adapt if it is not the good webserver)
runagent -m webserver1

# connect to container
podman exec -ti sftpgo sh

# change the password of admin user
sftpgo resetpwd --admin admin
```
Installation documentation: https://github.com/drakkan/sftpgo/blob/main/docs/full-configuration.md

 We ask to traefik an external port to use it with sftp, see the Env var : `SFTP_TCP_PORT`
 
If you want to upload files to the virtualhost:
`sftp -P SFTP_TCP_PORT 9001@foo.com`

once connected you could use some scp command
```
lls # ls the local file system
ls # ls the remote file system
lcd # change directory on the local path
cd # change directory of remote file system
put -r * # scp all local files to the remote folder (cp folders recusively) 
```
so to send all local files once connected (default password is 9001) 
```
sftp -P 3092 9001@foo.domain.org
lcd /path/files
put -r *
```

## alternative method : pull the website

Instead of pushing website content to an SFTP server, you can pull the content directly from the container. This method simplifies the content management

To pull website content from inside the container once the virtualhost has been created (the vhost ID is the default sftp login: 9001, 9002, 9003, ... ):

- Connect to the container:
  `runagent -m webserver1 podman exec -ti nginx ash`
- Navigate to the root directory of your virtualhost:
 `cd /usr/share/nginx/html/9001`
- Use commands like wget to get the latest content , for  rsync (to sync files), or git (to pull from a repository) you need to manually first install them each time you restart the container
  `apk add rsync git`
- permissions can be managed (must be adapted to the website)
  `chown nginx:root -R /usr/share/nginx/html/9001`

### Create API key

Sftpgo has a rest api that we can use by an API key, this is how we created it

- drop a default configuration with `/home/webserver*/.config/state/sftpgo.conf.d/admin.json` when we create the sftpgo container
- create with imageroot/actions/create-module/60sftpgo_create_secret the short lived token, then ask the API_key
- store the API_KEY to `/home/webserver*/.config/state/sftpgo.conf.d/API_KEY`

The API_KEY is asked to do all administrative tasks

https://sftpgo.stoplight.io/docs/sftpgo

## Install

Instantiate the module with:

    add-module ghcr.io/nethserver/webserver:latest 1

The output of the command will return the instance name.
Output example:

    {"module_id": "webserver1", "image_name": "webserver", "image_url": "ghcr.io/nethserver/webserver:latest"}

Let's assume that the webserver instance is named `webserver1`.


## Configure


We use a software called sftpgo as a sftp server to upload web content to the webserver module. default URL is http://foo.com/sftpgo but you can modify it 

Launch `configure-module`, by setting the following parameters:
- `path`: <name of the web path>
- `http2https`: <true|false>


Example:
```
api-cli run  configure-module --agent module/webserver1 --data - <<EOF
{ 
"path":"/sftpgo",
"http2https": true
}
EOF
```
The above command will:
- start and configure the sftpgo instance
- force http to https


Send a test HTTP request to the webserver backend service:

    curl http://127.0.0.1/sftpgo/


## Create vhost

a vhost can be created by the api-cli command

We use a container with nginx and another container for the php-fpm configuration (actually availlable PHP 7.4,8.0,8.1,8.2,8.3,8.4,8.5)

Launch `create-vhost`, by setting the following parameters:
- `PhpVersion`: Set the version of php needed, can be `''(no php), 7.4,8.0,8.1,8.2,8.3,8.4,8.5`
- `ServerNames`: set the domain name of the vhost, it must be an array
- `MemoryLimit`: This sets the maximum amount of memory that a script is allowed to allocate. use `MB`
- `AllowUrlfOpen` : This option enables the URL-aware fopen wrappers that enable accessing URL object like files. use `enabled|disabled`
- `UploadMaxFilesize`: The maximum size of an uploaded file. use `MB`
- `PostMaxSize`: Sets max size of post data allowed. use `MB`
- `MaxExecutionTime`: This sets the maximum time in seconds a script is allowed to run before it is terminated by the parser. use `0` (unlimited) or the time in second
- `MaxFileUploads`: The maximum number of files allowed to be uploaded simultaneously. use `MB`
- `lets_encrypt`: Use let'encrypt or self signed certificate: use `true|false`
- `http2https`: force the redirection to https. use `true|false`
- `Indexes`: List the files inside the webroot folder. use `enabled|disabled`
- `status`: enable the virtualhost in the configuration of nginx and php-fpm: use `enabled|disabled`

Example:
```
api-cli run  create-vhost --agent module/webserver1 --data - <<EOF
{ 
"PhpVersion": "7.4", 
"ServerNames": ["toto.com","foo.com"],
"MemoryLimit": 512,
"AllowUrlfOpen": "disabled",
"UploadMaxFilesize": 4,
"PostMaxSize": 8,
"MaxExecutionTime":0,
"MaxFileUploads":20,
"lets_encrypt": false,
"http2https": true,
"Indexes": "disabled",
"status": "enabled"
}
EOF
```

The above command will:
- start and configure the vhost with two domain names
- force http to https
- set the php version to 7.4
- set php MemoryLimit to 512MB
- set php AllowUrlfOpen to disabled
- set php UploadMaxFilesize to 4MB
- set php PostMaxSize to 8MB
- set php MaxExecutionTime to 0 (unlimited)
- set php MaxFileUploads to 20
- set letsencrypt certificate to false
- set force http to https 
- set web indexes enabled
- enable the vhost in the nginx configuration

## update  vhost

a vhost can be updated by the api-cli command, the old route to traefik will be removed then the new routes will be added

We need to know what virtualhost configuration we will modify, therefore we use the TCP php-fpm port as the ID of the virtualhost. 
The TCP port of the php-fpm port is unique, each virtualhost gets a nex tcp port number 

Launch `update-vhost`, by setting the following parameters:
- `port`: The tcp port of php-fpm, it is used as an ID for the virtualhost
- `PhpVersion`: Set the version of php needed, can be `''(no php), 7.4,8.0,8.1,8.2,8.3,8.4,8.5`
- `ServerNames`: set the domain name of the vhost, it must be an array
- `MemoryLimit`: This sets the maximum amount of memory that a script is allowed to allocate. use `MB`
- `AllowUrlfOpen` : This option enables the URL-aware fopen wrappers that enable accessing URL object like files. use `enabled|disabled`
- `UploadMaxFilesize`: The maximum size of an uploaded file. use `MB`
- `PostMaxSize`: Sets max size of post data allowed. use `MB`
- `MaxExecutionTime`: This sets the maximum time in seconds a script is allowed to run before it is terminated by the parser. use `0` (unlimited) or the time in second
- `MaxFileUploads`: The maximum number of files allowed to be uploaded simultaneously. use `MB`
- `lets_encrypt`: Use let'encrypt or self signed certificate: use `true|false`
- `http2https`: force the redirection to https. use `true|false`
- `Indexes`: List the files inside the webroot folder. use `enabled|disabled`
- `status`: enable the virtualhost in the configuration of nginx and php-fpm: use `enabled|disabled`

Example:
```
api-cli run  update-vhost --agent module/webserver1 --data - <<EOF
{ 
"PhpVersion": "8.1", 
"ServerNames": ["toto.com","foo.com"],
"MemoryLimit": 512,
"AllowUrlfOpen": "enabled",
"UploadMaxFilesize": 4,
"PostMaxSize": 8,
"MaxExecutionTime":0,
"MaxFileUploads":20,
"Port":9001,
"lets_encrypt": false,
"http2https": true,
"Indexes": "disabled",
"status": "enabled"
}
EOF
```

The above command will:
- modify the virtualhost with the ID `9001` (`"Port":9001`)
- start and configure the vhost with two domain names
- force http to https
- set the php version to 8.1
- set php MemoryLimit to 512MB
- set php AllowUrlfOpen to enabled
- set php UploadMaxFilesize to 4MB
- set php PostMaxSize to 8MB
- set php MaxExecutionTime to 0 (unlimited)
- set php MaxFileUploads to 20
- set letsencrypt certificate to false
- set force http to https 
- set web indexes disabled
- enable the vhost in the nginx configuration

## destroy vhost

You can remove a vhost, we need to knwo the ID of the virtualhost and the domain names

Launch `destroy-vhost`, by setting the following parameters:

- `Port`:  The tcp port of php-fpm, it is used as an ID for the virtualhost
- `ServerNames`: it is the domain name of the vhost, it must be an array

Examples:

```
api-cli run  destroy-vhost --agent module/webserver1 --data - <<EOF
{ 
"ServerNames": ["toto.com","foo.com"],"port":9101
}
EOF
```

It will destroy the vhost with the ID 9001 and it will remove the traefik routes `["toto.com","foo.com"]`


## get the configuration

You can retrieve the configuration with 

```
api-cli run get-configuration --agent module/webserver1 --data null | jq
Warning: using user "cluster" credentials from the environment
{
  "virtualhost": [
    {
      "ServerNames": [
        "toto.be",
        "foo.be"
      ],
      "Port": 9001,
      "PhpVersion": "7.4",
      "memorylimit": 512,
      "allowurlfopen": "disabled",
      "uploadmaxfilesize": 4,
      "postmaxsize": 8,
      "maxexecutiontime": 0,
      "maxfileuploads": 20,
      "Indexes": "disabled",
      "status": "enabled",
      "name": "9001"
    },
    {
      "ServerNames": [
        "toto.fr",
        "foo.fr"
      ],
      "Port": 9002,
      "PhpVersion": "",
      "memorylimit": 512,
      "allowurlfopen": "disabled",
      "uploadmaxfilesize": 4,
      "postmaxsize": 8,
      "maxexecutiontime": 0,
      "maxfileuploads": 20,
      "Indexes": "disabled",
      "status": "enabled",
      "name": "9002"
    }
  ],
  "sftp_tcp_port": 20029,
  "path": "/sftpgo",
  "http2https": true
}
```

## Uninstall

To uninstall the instance:

    remove-module --no-preserve webserver1

## Testing

Test the module using the `test-module.sh` script:


    ./test-module.sh <NODE_ADDR> ghcr.io/nethserver/webserver:latest

The tests are made using [Robot Framework](https://robotframework.org/)

## UI translation

Translated with [Weblate](https://hosted.weblate.org/projects/ns8/).

To setup the translation process:

- add [GitHub Weblate app](https://docs.weblate.org/en/latest/admin/continuous.html#github-setup) to your repository
- add your repository to [hosted.weblate.org]((https://hosted.weblate.org) or ask a NethServer developer to add it to ns8 Weblate project
