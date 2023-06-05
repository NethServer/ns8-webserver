# Untitled undefined type in Get webserver configuration Schema

```txt
http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items
```



| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                    |
| :------------------ | :--------- | :------------- | :----------- | :---------------- | :-------------------- | :------------------ | :---------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [set-route-input.json\*](traefik/set-route-input.json "open original schema") |

## items Type

unknown

# items Properties

| Property                                | Type      | Required | Nullable       | Defined by                                                                                                                                                                                                               |
| :-------------------------------------- | :-------- | :------- | :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [ServerNames](#servernames)             | `array`   | Optional | cannot be null | [Get webserver configuration](set-route-input-virtualhost-items-items-properties-servernames.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/ServerNames")             |
| [name](#name)                           | `string`  | Optional | cannot be null | [Get webserver configuration](set-route-input-virtualhost-items-items-properties-name.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/name")                           |
| [port](#port)                           | `integer` | Optional | cannot be null | [Get webserver configuration](set-route-input-virtualhost-items-items-properties-port.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/port")                           |
| [PhpVersion](#phpversion)               | `string`  | Optional | cannot be null | [Get webserver configuration](set-route-input-virtualhost-items-items-properties-phpversion.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/PhpVersion")               |
| [MemoryLimit](#memorylimit)             | `integer` | Optional | cannot be null | [Get webserver configuration](set-route-input-virtualhost-items-items-properties-memorylimit.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/MemoryLimit")             |
| [AllowUrlfOpen](#allowurlfopen)         | `string`  | Optional | cannot be null | [Get webserver configuration](set-route-input-virtualhost-items-items-properties-allowurlfopen.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/AllowUrlfOpen")         |
| [UploadMaxFilesize](#uploadmaxfilesize) | `integer` | Optional | cannot be null | [Get webserver configuration](set-route-input-virtualhost-items-items-properties-uploadmaxfilesize.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/UploadMaxFilesize") |
| [PostMaxSize](#postmaxsize)             | `integer` | Optional | cannot be null | [Get webserver configuration](set-route-input-virtualhost-items-items-properties-postmaxsize.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/PostMaxSize")             |
| [MaxExecutionTime](#maxexecutiontime)   | `integer` | Optional | cannot be null | [Get webserver configuration](set-route-input-virtualhost-items-items-properties-maxexecutiontime.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/MaxExecutionTime")   |
| [MaxFileUploads](#maxfileuploads)       | `integer` | Optional | cannot be null | [Get webserver configuration](set-route-input-virtualhost-items-items-properties-maxfileuploads.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/MaxFileUploads")       |

## ServerNames

Fully qualified domain names as virtualhost.

`ServerNames`

*   is optional

*   Type: `string[]`

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-virtualhost-items-items-properties-servernames.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/ServerNames")

### ServerNames Type

`string[]`

## name



`name`

*   is optional

*   Type: `string`

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-virtualhost-items-items-properties-name.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/name")

### name Type

`string`

## port

The port of the phpfpm pool

`port`

*   is optional

*   Type: `integer` ([port](set-route-input-virtualhost-items-items-properties-port.md))

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-virtualhost-items-items-properties-port.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/port")

### port Type

`integer` ([port](set-route-input-virtualhost-items-items-properties-port.md))

### port Constraints

**minimum**: the value of this number must greater than or equal to: `9001`

## PhpVersion

Could be 7.4 or 8.0 or 8.1 or ''

`PhpVersion`

*   is optional

*   Type: `string` ([PhpVersion](set-route-input-virtualhost-items-items-properties-phpversion.md))

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-virtualhost-items-items-properties-phpversion.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/PhpVersion")

### PhpVersion Type

`string` ([PhpVersion](set-route-input-virtualhost-items-items-properties-phpversion.md))

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

*   is optional

*   Type: `integer` ([MemoryLimit](set-route-input-virtualhost-items-items-properties-memorylimit.md))

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-virtualhost-items-items-properties-memorylimit.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/MemoryLimit")

### MemoryLimit Type

`integer` ([MemoryLimit](set-route-input-virtualhost-items-items-properties-memorylimit.md))

### MemoryLimit Constraints

**minimum**: the value of this number must greater than or equal to: `32`

## AllowUrlfOpen

Turn off or on the AllowUrlfOpen

`AllowUrlfOpen`

*   is optional

*   Type: `string` ([AllowUrlfOpen](set-route-input-virtualhost-items-items-properties-allowurlfopen.md))

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-virtualhost-items-items-properties-allowurlfopen.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/AllowUrlfOpen")

### AllowUrlfOpen Type

`string` ([AllowUrlfOpen](set-route-input-virtualhost-items-items-properties-allowurlfopen.md))

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

*   is optional

*   Type: `integer` ([UploadMaxFilesize](set-route-input-virtualhost-items-items-properties-uploadmaxfilesize.md))

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-virtualhost-items-items-properties-uploadmaxfilesize.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/UploadMaxFilesize")

### UploadMaxFilesize Type

`integer` ([UploadMaxFilesize](set-route-input-virtualhost-items-items-properties-uploadmaxfilesize.md))

### UploadMaxFilesize Constraints

**minimum**: the value of this number must greater than or equal to: `4`

## PostMaxSize

The maximum of PostMaxSize allowed to the php script

`PostMaxSize`

*   is optional

*   Type: `integer` ([PostMaxSize](set-route-input-virtualhost-items-items-properties-postmaxsize.md))

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-virtualhost-items-items-properties-postmaxsize.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/PostMaxSize")

### PostMaxSize Type

`integer` ([PostMaxSize](set-route-input-virtualhost-items-items-properties-postmaxsize.md))

### PostMaxSize Constraints

**minimum**: the value of this number must greater than or equal to: `8`

## MaxExecutionTime

The maximum of MaxExecutionTime allowed to the php script

`MaxExecutionTime`

*   is optional

*   Type: `integer` ([MaxExecutionTime](set-route-input-virtualhost-items-items-properties-maxexecutiontime.md))

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-virtualhost-items-items-properties-maxexecutiontime.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/MaxExecutionTime")

### MaxExecutionTime Type

`integer` ([MaxExecutionTime](set-route-input-virtualhost-items-items-properties-maxexecutiontime.md))

### MaxExecutionTime Constraints

**minimum**: the value of this number must greater than or equal to: `0`

## MaxFileUploads

The maximum of MaxFileUploads allowed to the php script

`MaxFileUploads`

*   is optional

*   Type: `integer` ([MaxFileUploads](set-route-input-virtualhost-items-items-properties-maxfileuploads.md))

*   cannot be null

*   defined in: [Get webserver configuration](set-route-input-virtualhost-items-items-properties-maxfileuploads.md "http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/MaxFileUploads")

### MaxFileUploads Type

`integer` ([MaxFileUploads](set-route-input-virtualhost-items-items-properties-maxfileuploads.md))

### MaxFileUploads Constraints

**minimum**: the value of this number must greater than or equal to: `20`
