# Get webserver configuration Schema

```txt
http://schema.nethserver.org/traefik/set-route-input.json
```

Get webserver configuration

| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                  |
| :------------------ | :--------- | :------------- | :----------- | :---------------- | :-------------------- | :------------------ | :-------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [set-route-input.json](traefik/set-route-input.json "open original schema") |

## Get webserver configuration Type

`object` ([Get webserver configuration](set-route-input.md))

## Get webserver configuration Examples

```json
{
  "virtualhost": [
    {
      "PhpVersion": "7.4",
      "ServerNames": [
        "toto.com",
        "prout.com"
      ],
      "MemoryLimit": 512,
      "AllowUrlfOpen": "disabled",
      "UploadMaxFilesize": 4,
      "PostMaxSize": 8,
      "MaxExecutionTime": 0,
      "MaxFileUploads": 20,
      "port": 9001,
      "name": "9001"
    }
  ],
  "sftp_tcp_port": 20014,
  "path": "/sftpgo",
  "http2https": true,
  "hostname": "foo.domain.com"
}
```

# Get webserver configuration Properties

| Property                          | Type          | Required | Nullable       | Defined by                                                                                                                                                                |
| :-------------------------------- | :------------ | :------- | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [http2https](#http2https)         | `boolean`     | Required | cannot be null | [Get webserver configuration](set-route-input-properties-http-to-https-redirection.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/http2https") |
| [sftp\_tcp\_port](#sftp_tcp_port) | `integer`     | Required | cannot be null | [Get webserver configuration](set-route-input-properties-port.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/sftp_tcp_port")                   |
| [path](#path)                     | `string`      | Required | cannot be null | [Get webserver configuration](set-route-input-properties-path.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/path")                            |
| [hostname](#hostname)             | Not specified | Required | cannot be null | [Get webserver configuration](set-route-input-properties-hostname-of-the-node.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/hostname")        |

## http2https

Redirect all the HTTP requests to HTTPS

`http2https`

*   is required

*   Type: `boolean` ([HTTP to HTTPS redirection](set-route-input-properties-http-to-https-redirection.md))

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-properties-http-to-https-redirection.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/http2https")

### http2https Type

`boolean` ([HTTP to HTTPS redirection](set-route-input-properties-http-to-https-redirection.md))

## sftp\_tcp\_port

The port of the sftp service

`sftp_tcp_port`

*   is required

*   Type: `integer` ([port](set-route-input-properties-port.md))

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-properties-port.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/sftp_tcp_port")

### sftp\_tcp\_port Type

`integer` ([port](set-route-input-properties-port.md))

### sftp\_tcp\_port Constraints

**maximum**: the value of this number must smaller than or equal to: `65535`

**minimum**: the value of this number must greater than or equal to: `1024`

## path

web path for the web application, like '/sftpgo'

`path`

*   is required

*   Type: `string`

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-properties-path.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/path")

### path Type

`string`

### path Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
^/?[a-zA-Z0-9_-]+/?$
```

[try pattern](https://regexr.com/?expression=%5E%2F%3F%5Ba-zA-Z0-9_-%5D%2B%2F%3F%24 "try regular expression with regexr.com")

## hostname

Host name of the node, like 'foo.domain.com'

`hostname`

*   is required

*   Type: unknown ([hostname of the node](set-route-input-properties-hostname-of-the-node.md))

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-properties-hostname-of-the-node.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/hostname")

### hostname Type

unknown ([hostname of the node](set-route-input-properties-hostname-of-the-node.md))

### hostname Constraints

**(international) hostname**: the string must be an (IDN) hostname, according to [RFC 5890, section 2.3.2.3](https://tools.ietf.org/html/rfc5890 "check the specification")
