# set-route input Schema

```txt
http://schema.nethserver.org/traefik/set-route-input.json
```

Validate virtualhost creation

| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                  |
| :------------------ | :--------- | :------------- | :----------- | :---------------- | :-------------------- | :------------------ | :-------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [set-route-input.json](traefik/set-route-input.json "open original schema") |

## set-route input Type

`object` ([set-route input](set-route-input.md))

## set-route input Examples

```json
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
  "lets_encrypt": false,
  "http2https": true,
  "Indexes": "disabled",
  "status": "enabled"
}
```

# set-route input Properties

| Property                                | Type      | Required | Nullable       | Defined by                                                                                                                                                     |
| :-------------------------------------- | :-------- | :------- | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [ServerNames](#servernames)             | `array`   | Required | cannot be null | [set-route input](set-route-input-properties-servernames.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/ServerNames")               |
| [PhpVersion](#phpversion)               | `string`  | Required | cannot be null | [set-route input](set-route-input-properties-phpversion.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/PhpVersion")                 |
| [MemoryLimit](#memorylimit)             | `integer` | Required | cannot be null | [set-route input](set-route-input-properties-memorylimit.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/MemoryLimit")               |
| [status](#status)                       | `string`  | Required | cannot be null | [set-route input](set-route-input-properties-indexes.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/status")                        |
| [Indexes](#indexes)                     | `string`  | Required | cannot be null | [set-route input](set-route-input-properties-indexes-1.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/Indexes")                     |
| [AllowUrlfOpen](#allowurlfopen)         | `string`  | Required | cannot be null | [set-route input](set-route-input-properties-allowurlfopen.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/AllowUrlfOpen")           |
| [UploadMaxFilesize](#uploadmaxfilesize) | `integer` | Required | cannot be null | [set-route input](set-route-input-properties-uploadmaxfilesize.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/UploadMaxFilesize")   |
| [PostMaxSize](#postmaxsize)             | `integer` | Required | cannot be null | [set-route input](set-route-input-properties-postmaxsize.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/PostMaxSize")               |
| [MaxExecutionTime](#maxexecutiontime)   | `integer` | Required | cannot be null | [set-route input](set-route-input-properties-maxexecutiontime.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/MaxExecutionTime")     |
| [MaxFileUploads](#maxfileuploads)       | `integer` | Required | cannot be null | [set-route input](set-route-input-properties-maxfileuploads.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/MaxFileUploads")         |
| [lets\_encrypt](#lets_encrypt)          | `boolean` | Required | cannot be null | [set-route input](set-route-input-properties-lets-encrypt-certificate.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/lets_encrypt") |
| [http2https](#http2https)               | `boolean` | Required | cannot be null | [set-route input](set-route-input-properties-http-to-https-redirection.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/http2https")  |

## ServerNames

Fully qualified domain names as virtualhost.

`ServerNames`

*   is required

*   Type: `string[]`

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-servernames.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/ServerNames")

### ServerNames Type

`string[]`

## PhpVersion

Could be 7.4 or 8.0 or 8.1 or ''

`PhpVersion`

*   is required

*   Type: `string` ([PhpVersion](set-route-input-properties-phpversion.md))

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-phpversion.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/PhpVersion")

### PhpVersion Type

`string` ([PhpVersion](set-route-input-properties-phpversion.md))

### PhpVersion Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
(^[0-9][.][0-9]$|^$)
```

[try pattern](https://regexr.com/?expression=\(%5E%5B0-9%5D%5B.%5D%5B0-9%5D%24%7C%5E%24\) "try regular expression with regexr.com")

**RegEx**: the string must be a regular expression, according to [ECMA-262](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf "check the specification")

## MemoryLimit

The maximum of memory allowed to the php script

`MemoryLimit`

*   is required

*   Type: `integer` ([MemoryLimit](set-route-input-properties-memorylimit.md))

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-memorylimit.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/MemoryLimit")

### MemoryLimit Type

`integer` ([MemoryLimit](set-route-input-properties-memorylimit.md))

### MemoryLimit Constraints

**minimum**: the value of this number must greater than or equal to: `32`

## status

Turn off or on the indexes

`status`

*   is required

*   Type: `string` ([Indexes](set-route-input-properties-indexes.md))

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-indexes.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/status")

### status Type

`string` ([Indexes](set-route-input-properties-indexes.md))

### status Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
^(enabled|disabled)$
```

[try pattern](https://regexr.com/?expression=%5E\(enabled%7Cdisabled\)%24 "try regular expression with regexr.com")

**RegEx**: the string must be a regular expression, according to [ECMA-262](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf "check the specification")

## Indexes

Turn off or on the indexes

`Indexes`

*   is required

*   Type: `string` ([Indexes](set-route-input-properties-indexes-1.md))

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-indexes-1.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/Indexes")

### Indexes Type

`string` ([Indexes](set-route-input-properties-indexes-1.md))

### Indexes Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
^(enabled|disabled)$
```

[try pattern](https://regexr.com/?expression=%5E\(enabled%7Cdisabled\)%24 "try regular expression with regexr.com")

**RegEx**: the string must be a regular expression, according to [ECMA-262](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf "check the specification")

## AllowUrlfOpen

Turn off or on the AllowUrlfOpen

`AllowUrlfOpen`

*   is required

*   Type: `string` ([AllowUrlfOpen](set-route-input-properties-allowurlfopen.md))

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-allowurlfopen.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/AllowUrlfOpen")

### AllowUrlfOpen Type

`string` ([AllowUrlfOpen](set-route-input-properties-allowurlfopen.md))

### AllowUrlfOpen Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
^(enabled|disabled)$
```

[try pattern](https://regexr.com/?expression=%5E\(enabled%7Cdisabled\)%24 "try regular expression with regexr.com")

**RegEx**: the string must be a regular expression, according to [ECMA-262](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf "check the specification")

## UploadMaxFilesize

The maximum of UploadMaxFilesize allowed to the php script

`UploadMaxFilesize`

*   is required

*   Type: `integer` ([UploadMaxFilesize](set-route-input-properties-uploadmaxfilesize.md))

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-uploadmaxfilesize.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/UploadMaxFilesize")

### UploadMaxFilesize Type

`integer` ([UploadMaxFilesize](set-route-input-properties-uploadmaxfilesize.md))

### UploadMaxFilesize Constraints

**minimum**: the value of this number must greater than or equal to: `4`

## PostMaxSize

The maximum of PostMaxSize allowed to the php script

`PostMaxSize`

*   is required

*   Type: `integer` ([PostMaxSize](set-route-input-properties-postmaxsize.md))

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-postmaxsize.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/PostMaxSize")

### PostMaxSize Type

`integer` ([PostMaxSize](set-route-input-properties-postmaxsize.md))

### PostMaxSize Constraints

**minimum**: the value of this number must greater than or equal to: `8`

## MaxExecutionTime

The maximum of MaxExecutionTime allowed to the php script

`MaxExecutionTime`

*   is required

*   Type: `integer` ([MaxExecutionTime](set-route-input-properties-maxexecutiontime.md))

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-maxexecutiontime.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/MaxExecutionTime")

### MaxExecutionTime Type

`integer` ([MaxExecutionTime](set-route-input-properties-maxexecutiontime.md))

### MaxExecutionTime Constraints

**minimum**: the value of this number must greater than or equal to: `0`

## MaxFileUploads

The maximum of MaxFileUploads allowed to the php script

`MaxFileUploads`

*   is required

*   Type: `integer` ([MaxFileUploads](set-route-input-properties-maxfileuploads.md))

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-maxfileuploads.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/MaxFileUploads")

### MaxFileUploads Type

`integer` ([MaxFileUploads](set-route-input-properties-maxfileuploads.md))

### MaxFileUploads Constraints

**minimum**: the value of this number must greater than or equal to: `20`

## lets\_encrypt

Request a valid Let's Encrypt certificate.

`lets_encrypt`

*   is required

*   Type: `boolean` ([Let's Encrypt certificate](set-route-input-properties-lets-encrypt-certificate.md))

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-lets-encrypt-certificate.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/lets_encrypt")

### lets\_encrypt Type

`boolean` ([Let's Encrypt certificate](set-route-input-properties-lets-encrypt-certificate.md))

## http2https

Redirect all the HTTP requests to HTTPS

`http2https`

*   is required

*   Type: `boolean` ([HTTP to HTTPS redirection](set-route-input-properties-http-to-https-redirection.md))

*   cannot be null

*   defined in: [set-route input](set-route-input-properties-http-to-https-redirection.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/http2https")

### http2https Type

`boolean` ([HTTP to HTTPS redirection](set-route-input-properties-http-to-https-redirection.md))
