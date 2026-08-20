# hostname of the node Schema

```txt
http://schema.nethserver.org/traefik/set-route-input.json#/properties/hostname
```

Host name of the node, like 'foo.domain.com'

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                    |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :---------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [set-route-input.json\*](traefik/set-route-input.json "open original schema") |

## hostname Type

unknown ([hostname of the node](set-route-input-properties-hostname-of-the-node.md))

## hostname Constraints

**(international) hostname**: the string must be an (IDN) hostname, according to [RFC 5890, section 2.3.2.3](https://tools.ietf.org/html/rfc5890 "check the specification")
