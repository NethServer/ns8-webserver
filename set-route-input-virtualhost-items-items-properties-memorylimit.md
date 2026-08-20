# MemoryLimit Schema

```txt
http://schema.nethserver.org/traefik/set-route-input.json#/virtualhost/items/items/properties/MemoryLimit
```

The maximum of memory allowed to the php script

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                    |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :---------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [set-route-input.json\*](traefik/set-route-input.json "open original schema") |

## MemoryLimit Type

`integer` ([MemoryLimit](set-route-input-virtualhost-items-items-properties-memorylimit.md))

## MemoryLimit Constraints

**minimum**: the value of this number must greater than or equal to: `32`
