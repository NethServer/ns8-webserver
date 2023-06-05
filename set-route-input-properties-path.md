# Untitled string in Get webserver configuration Schema

```txt
http://schema.nethserver.org/traefik/set-route-input.json#/properties/path
```

web path for the web application, like '/sftpgo'

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                    |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :---------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [set-route-input.json\*](traefik/set-route-input.json "open original schema") |

## path Type

`string`

## path Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
^/?[a-zA-Z0-9_-]+/?$
```

[try pattern](https://regexr.com/?expression=%5E%2F%3F%5Ba-zA-Z0-9_-%5D%2B%2F%3F%24 "try regular expression with regexr.com")
