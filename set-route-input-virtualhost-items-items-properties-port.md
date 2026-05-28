# port Schema

```txt
http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/port
```

The port of the phpfpm pool

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                    |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :---------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [set-route-input.json\*](traefik/set-route-input.json "open original schema") |

## port Type

`integer` ([port](set-route-input-virtualhost-items-items-properties-port.md))

## port Constraints

**minimum**: the value of this number must greater than or equal to: `9001`
