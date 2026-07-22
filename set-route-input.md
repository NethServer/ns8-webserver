# set-route input Schema

```txt
http://schema.nethserver.org/traefik/set-route-input.json
```

Validate virtualhost removal

| Abstract            | Extensible | Status         | Identifiable | Custom Properties | Additional Properties | Access Restrictions | Defined In                                                                  |
| :------------------ | :--------- | :------------- | :----------- | :---------------- | :-------------------- | :------------------ | :-------------------------------------------------------------------------- |
| Can be instantiated | No         | Unknown status | No           | Forbidden         | Allowed               | none                | [set-route-input.json](traefik/set-route-input.json "open original schema") |

## set-route input Type

`object` ([set-route input](set-route-input.md))

## set-route input Examples

```json
{
  "ServerNames": [
    "toto.com",
    "prout.com"
  ],
  "port": 9001
}
```

# set-route input Properties

| Property                    | Type      | Required | Nullable       | Defined by                                                                                                                                       |
| :-------------------------- | :-------- | :------- | :------------- | :----------------------------------------------------------------------------------------------------------------------------------------------- |
| [ServerNames](#servernames) | `array`   | Required | cannot be null | [set-route input](set-route-input-properties-servernames.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/ServerNames") |
| [port](#port)               | `integer` | Required | cannot be null | [set-route input](set-route-input-properties-port.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/port")               |

## ServerNames

Fully qualified domain names as virtualhost.

`ServerNames`

* is required

* Type: `string[]`

* cannot be null

* defined in: [set-route input](set-route-input-properties-servernames.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/ServerNames")

### ServerNames Type

`string[]`

## port

The port of the phpfpm pool

`port`

* is required

* Type: `integer` ([port](set-route-input-properties-port.md))

* cannot be null

* defined in: [set-route input](set-route-input-properties-port.md "http://schema.nethserver.org/traefik/set-route-input.json#/properties/port")

### port Type

`integer` ([port](set-route-input-properties-port.md))

### port Constraints

**minimum**: the value of this number must greater than or equal to: `9001`
