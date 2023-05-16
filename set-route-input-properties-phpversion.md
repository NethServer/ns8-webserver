# PhpVersion Schema

```txt
http://schema.nethserver.org/traefik/set-route-input.json#/properties/PhpVersion
```

Could be 7.4 or 8.0 or 8.1 or ''

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                    |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :---------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [set-route-input.json\*](traefik/set-route-input.json "open original schema") |

## PhpVersion Type

`string` ([PhpVersion](set-route-input-properties-phpversion.md))

## PhpVersion Constraints

**pattern**: the string must match the following regular expression:&#x20;

```regexp
(^[0-9][.][0-9]$|^$)
```

[try pattern](https://regexr.com/?expression=\(%5E%5B0-9%5D%5B.%5D%5B0-9%5D%24%7C%5E%24\) "try regular expression with regexr.com")

**RegEx**: the string must be a regular expression, according to [ECMA-262](http://www.ecma-international.org/publications/files/ECMA-ST/Ecma-262.pdf "check the specification")
