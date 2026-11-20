# Admin guide

The examples use the instance `webserver1` and the virtual host `9001`.
Adapt both to your setup.

## UI pages

**Status** shows the SFTPGo WebAdmin and WebClient URLs and the external SFTP
port. SFTPGo is not running until the Settings page has been saved once.

**Settings** configures SFTPGo: its web path, its external SFTP port, and
whether that port is open in the firewall.

**Virtual hosts** creates, edits, disables and deletes the websites.

## Settings

`configure-module` takes four parameters, all required:

| Parameter | Type | Meaning |
| --- | --- | --- |
| `path` | string | Web path of the SFTPGo web interface, for example `/sftpgo`. It must not be used by another route in Traefik. |
| `http2https` | boolean | Redirect HTTP to HTTPS for that path. |
| `sftp_tcp_port` | integer, 1024 to 65535 | External SFTP port. It must be free on the node. |
| `sftpgo_service` | boolean | Open `sftp_tcp_port` in the firewall. When false, SFTP is reachable only from the node. |

```sh
api-cli run module/webserver1/configure-module --data - <<EOF
{
  "path": "/sftpgo",
  "http2https": true,
  "sftp_tcp_port": 3092,
  "sftpgo_service": true
}
EOF
```

The SFTPGo web interface answers on the node FQDN, for example
`https://node.example.com/sftpgo/`.

## Virtual hosts

### Parameters

`create-vhost` and `update-vhost` take the same parameters, all required.
`update-vhost` also needs `Port`, the ID of the virtual host.

| Parameter | Type | Meaning |
| --- | --- | --- |
| `ServerNames` | array of host names | Domain names of the site. Each name gets its own Traefik route. |
| `PhpVersion` | string | `7.4`, `8.0`, `8.1`, `8.2`, `8.3`, `8.4`, `8.5`, or `""` for a static site. |
| `MemoryLimit` | integer, MB, min 32 | PHP `memory_limit`. |
| `AllowUrlfOpen` | `enabled` or `disabled` | PHP `allow_url_fopen`. |
| `UploadMaxFilesize` | integer, MB, min 4 | PHP `upload_max_filesize`. |
| `PostMaxSize` | integer, MB, min 8 | PHP `post_max_size`. |
| `MaxExecutionTime` | integer, seconds | PHP `max_execution_time` and `max_input_time`. `0` means no limit. |
| `MaxFileUploads` | integer, min 20 | PHP `max_file_uploads`, a number of files. |
| `Indexes` | `enabled` or `disabled` | nginx `autoindex`: list the files of a folder without an index page. |
| `status` | `enabled` or `disabled` | A disabled site keeps its files and settings, but nginx and php-fpm stop serving it. |
| `lets_encrypt` | boolean | Ask a Let's Encrypt certificate for every server name. |
| `http2https` | boolean | Redirect HTTP to HTTPS. |

The PHP values are set with `php_admin_value`, so the PHP code of the site
cannot change them.

### Create

```sh
api-cli run module/webserver1/create-vhost --data - <<EOF
{
  "ServerNames": ["example.com", "www.example.com"],
  "PhpVersion": "8.4",
  "MemoryLimit": 512,
  "AllowUrlfOpen": "disabled",
  "UploadMaxFilesize": 4,
  "PostMaxSize": 8,
  "MaxExecutionTime": 0,
  "MaxFileUploads": 20,
  "Indexes": "disabled",
  "status": "enabled",
  "lets_encrypt": true,
  "http2https": true
}
EOF
```

The new site gets the next free ID. The first one is `9001`. The action also
creates the SFTP user `9001` with the password `9001`. Change that password
right away.

### Update

Send the full configuration with `Port` set to the ID:

```sh
api-cli run module/webserver1/update-vhost --data - <<EOF
{
  "Port": 9001,
  "ServerNames": ["example.com", "www.example.com"],
  "PhpVersion": "8.5",
  "MemoryLimit": 512,
  "AllowUrlfOpen": "disabled",
  "UploadMaxFilesize": 4,
  "PostMaxSize": 8,
  "MaxExecutionTime": 0,
  "MaxFileUploads": 20,
  "Indexes": "disabled",
  "status": "enabled",
  "lets_encrypt": true,
  "http2https": true
}
EOF
```

The action deletes the old Traefik routes and creates the new ones. A PHP
version that no site uses anymore has its php-fpm container stopped.

### Delete

```sh
api-cli run module/webserver1/destroy-vhost --data '{"port": 9001, "ServerNames": ["example.com", "www.example.com"]}'
```

> [!WARNING]
> `destroy-vhost` deletes the web root of the site, its SFTP user and its
> php-fpm custom file. Take a copy of the files first if you need them.

The nginx custom file `conf.d/dyn-9001.custom` is left in place. It has no
effect once the site is gone. Remove it by hand.

### Read the configuration

```sh
api-cli run module/webserver1/get-configuration --data null | jq
```

It returns the list of virtual hosts with their parameters, the SFTPGo
settings, `sftpgo_isrunning`, `NextFpmPort` (the ID the next site will get)
and the node `hostname`.

## Upload the website

### With SFTP

Every site has an SFTP user named after its ID. Its home is the web root of
the site.

```sh
sftp -P 3092 9001@node.example.com
```

Once connected:

```text
lcd /path/to/site
put -r *
```

The same account logs in to the SFTPGo WebClient, at the SFTPGo path. rsync
and scp are allowed over SSH too:

```sh
rsync -av -e "ssh -p 3092" ./site/ 9001@node.example.com:/
```

### From inside the nginx container

You can also pull the content from the node:

```sh
runagent -m webserver1 podman exec -ti nginx ash
cd /usr/share/nginx/html/9001
wget https://example.com/site.tar.gz
```

`rsync` and `git` are not in the image. `apk add rsync git` installs them,
until the container restarts.

### Scheduled jobs

SFTPGo runs `crond`, and the crontab is backed up. For example, to mirror a
repository into a site every three hours:

```sh
runagent -m webserver1
crontab -e
```

```text
15 */3 * * * podman exec sftpgo rsync -aHS --partial --delete rsync://mirror.example.org/repo /srv/sftpgo/data/9001/
```

`podman exec sftpgo crontab -l` lists the jobs.

### Passwords

The SFTPGo admin and the site users change their password in the SFTPGo web
interface. If the admin password is lost:

```sh
runagent -m webserver1 podman exec -ti sftpgo sftpgo resetpwd --admin admin
```

See the [SFTPGo documentation](https://docs.sftpgo.com/) for the rest.

## Custom configuration

Each site has two custom files. The module creates them empty, never
overwrites them, and backs them up.

| File, under `~/.config/state/` | Included in | Use it for |
| --- | --- | --- |
| `conf.d/dyn-9001.custom` | the nginx `server` block of the site | `location`, `rewrite`, headers, access rules |
| `php8.4-fpm-custom.d/dyn-9001.custom` | the php-fpm pool of the site | `php_admin_value`, `php_admin_flag`, `env[...]`, pool settings |

The php-fpm file lives in the folder of the PHP version of the site.

The pool includes its custom file before the values set in the UI. A
custom `memory_limit`, `upload_max_filesize`, `post_max_size`,
`max_execution_time`, `max_input_time`, `max_file_uploads` or
`allow_url_fopen` is ignored. Change them in the virtual host settings.

Edit them as the module user, then reload the service:

```sh
runagent -m webserver1
vi conf.d/dyn-9001.custom
systemctl --user reload nginx.service

vi php8.4-fpm-custom.d/dyn-9001.custom
systemctl --user reload phpfpm@8.4.service
```

A file written as `root` must be given back to the module user:
`chown webserver1:webserver1 <file>`.

Do not store other files in `php*-fpm-custom.d/`. They are not backed up,
and every pool of the same PHP version can read them. To pass secrets to
an application, use `env[...]` in the pool custom file and `getenv()` in
the code:

```ini
env[DB_HOST] = 10.5.4.1
env[DB_PASSWORD] = secret
```

Then make the file readable by the module user only. The php-fpm master
still reads it:

```sh
chmod 600 php8.4-fpm-custom.d/dyn-9001.custom
```

## Hardening

The module does not change the PHP or nginx defaults, so existing sites keep
working. The PHP images ship no `php.ini`, so PHP runs on its built-in
defaults: `expose_php` and `display_errors` are on, session cookies are not
`HttpOnly`. You can harden each site with its custom files.

PHP, in `php8.4-fpm-custom.d/dyn-9001.custom`:

```ini
php_admin_flag[expose_php] = off
php_admin_flag[display_errors] = off
php_admin_flag[log_errors] = on
php_admin_flag[session.use_strict_mode] = on
php_admin_flag[session.cookie_httponly] = on
; only if the site is served over HTTPS
php_admin_flag[session.cookie_secure] = on
```

nginx, in `conf.d/dyn-9001.custom`:

```nginx
server_tokens off;
location ~ /\.(?!well-known/) {
    return 404;
}
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

The `location` rule hides `.git`, `.env` and other dot files, but keeps
`/.well-known/` reachable for Let's Encrypt, CalDAV, CardDAV, `security.txt`
and OpenID discovery.

Test the site after each change. With `display_errors` off, a PHP error
shows a blank page and goes to the log. A few applications set their own
session ID or read the session cookie from JavaScript, and break with
`use_strict_mode` or `cookie_httponly`.

## Isolation between sites

All PHP pools run as the same user (`daemon`, uid 1), and the site files
belong to that user. The PHP code of one site can read and write the files
of every other site of the same instance, including their configuration
and database credentials.

If a site runs an application you do not fully trust, or holds sensitive
data, give it its own webserver instance.

## Mail

The cluster smarthost settings are passed to every php-fpm container as
`SMTP_*` environment variables, and refreshed when the smarthost changes.
PHP `mail()` does not use them. The application must read them with
`getenv()` and send through SMTP itself, see
[Smarthost](architecture.md#smarthost).

## Backup and restore

The backup holds:

- the `websites` volume, with the files of every site
- the SFTPGo data and its API key
- the virtual host settings
- the custom files `conf.d/*.custom` and `php*-fpm-custom.d/*.custom`
- the crontab

Anything else you add under `~/.config/state/` is not backed up. Databases
belong to their own module and have their own backup.

Restore recreates the Traefik routes, starts nginx and SFTPGo, and starts the
php-fpm containers of the PHP versions in use.

## Troubleshooting

Logs of the module:

```sh
journalctl _UID=$(id -u webserver1) -f
```

Check the PHP extensions of one PHP version:

```sh
runagent -m webserver1 podman exec php8.4-fpm php /usr/local/bin/verify-runtime.php
```

It prints `All runtime checks passed`, or one line per failure.

Check the rendered nginx configuration:

```sh
runagent -m webserver1 podman exec nginx nginx -T
```

A site answers HTTP 502 when its php-fpm container is down:

```sh
runagent -m webserver1 systemctl --user status phpfpm@8.4.service
```

## Uninstall

```sh
remove-module --no-preserve webserver1
```

It removes the Traefik routes, closes the SFTP port and deletes every site.
