# port Schema

```txt
http://schema.nethserver.org/traefik/set-route-input.json#/properties/sftp_tcp_port
```

The port of the sftp service

| Abstract            | Extensible | Status         | Identifiable            | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                    |
| :------------------ | :--------- | :------------- | :---------------------- | :---------------- | :-------------------- | :------------------ | :---------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | Unknown identifiability | Forbidden         | Allowed               | none                | [set-route-input.json\*](traefik/set-route-input.json "open original schema") |

## sftp\_tcp\_port Type

`integer` ([port](set-route-input-properties-port.md))

## sftp\_tcp\_port Constraints

**maximum**: the value of this number must smaller than or equal to: `65535`

**minimum**: the value of this number must greater than or equal to: `1024`
