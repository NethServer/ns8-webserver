# AllowUrlfOpen Schema

```txt
http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/AllowUrlfOpen
```

Turn off or on the AllowUrlfOpen

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                    |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :---------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [set-route-input.json\*](traefik/set-route-input.json "open original schema") |

## AllowUrlfOpen Type

`string` ([AllowUrlfOpen](set-route-input-virtualhost-items-items-properties-allowurlfopen.md))

## AllowUrlfOpen Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
^(enabled|disabled)$
```

[try pattern](https://regexr.com/?expression=%5E\(enabled%7Cdisabled\)%24 "try regular expression with regexr.com")

**RegEx**: the string must be a regular expression, according to [ECMA-262](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf "check the specification")
