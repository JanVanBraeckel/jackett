# jackett with WebUI and OpenVPN

Docker container which runs the latest headless jackett client with WebUI while connecting to OpenVPN with iptables killswitch to prevent IP leakage when the tunnel goes down.

## Docker Features

- Base: Ubuntu 18.04
- Latest jackett
- Size: 403MB
- Selectively enable or disable OpenVPN support
- IP tables kill switch to prevent IP leaking when VPN connection fails
- Specify name servers to add to container
- Configure UID, GID, and UMASK for config files by jackett

# Run container from Docker registry

The container is available from the Docker registry and this is the simplest way to get it.
To run the container use this command:

```
$ docker run --privileged  -d \
              -v /your/jackett/path/:/config/jackett \
              -v /your/openvpn/client.conf:/config/client.ovpn \
              -e "VPN_ENABLED=yes" \
              -e "LAN_NETWORK=192.168.1.0/24" \
              -e "NAME_SERVERS=8.8.8.8,8.8.4.4" \
              -p 8080:8080 \
              -p 8999:8999 \
              -p 8999:8999/udp \
              janvanbraeckel/jackett
```

# Variables, Volumes, and Ports

## Environment Variables

| Variable       | Required | Function                                                              | Example                          |
| -------------- | -------- | --------------------------------------------------------------------- | -------------------------------- |
| `VPN_ENABLED`  | Yes      | Enable VPN? (yes/no) Default:yes                                      | `VPN_ENABLED=yes`                |
| `VPN_CONFIG`   | No       | Path to OpenVPN config file. Default: /config/client.ovpn             | `VPN_CONFIG=/config/client.conf` |
| `VPN_USERNAME` | No       | If username and password provided, configures ovpn file automatically | `VPN_USERNAME=ad8f64c02a2de`     |
| `VPN_PASSWORD` | No       | If username and password provided, configures ovpn file automatically | `VPN_PASSWORD=ac98df79ed7fb`     |
| `LAN_NETWORK`  | Yes      | Local Network with CIDR notation                                      | `LAN_NETWORK=192.168.1.0/24`     |
| `NAME_SERVERS` | No       | Comma delimited name servers                                          | `NAME_SERVERS=8.8.8.8,8.8.4.4`   |
| `PUID`         | No       | UID applied to config files                                           | `PUID=99`                        |
| `PGID`         | No       | GID applied to config files                                           | `PGID=100`                       |
| `UMASK`        | No       | GID applied to config files                                           | `UMASK=002`                      |

## Volumes

| Volume        | Required | Function                                 | Example                                         |
| ------------- | -------- | ---------------------------------------- | ----------------------------------------------- |
| `jackett`     | Yes      | jackett and OpenVPN config files         | `/your/config/path/:/config/jackett`            |
| `client.ovpn` | No       | OpenVPN config file if `VPN_ENABLED=yes` | `/your/openvpn/client.conf:/config/client.ovpn` |

## Ports

| Port   | Proto | Required | Function    | Example     |
| ------ | ----- | -------- | ----------- | ----------- |
| `9117` | TCP   | Yes      | jacket port | `9117:9117` |

# Access the WebUI

Access http://IPADDRESS:PORT from a browser on the same network.

## Default Credentials

| Credential       | Default Value |
| ---------------- | ------------- |
| `WebUI Username` | admin         |
| `WebUI Password` | adminadmin    |

# How to use OpenVPN

The container will fail to boot if `VPN_ENABLED` is set to yes or empty and a .ovpn is not present in the /config/openvpn directory. Drop a .ovpn file from your VPN provider into /config/openvpn and start the container again. You may need to edit the ovpn configuration file to load your VPN credentials from a file by setting `auth-user-pass`.

**Note:** The script will use the first ovpn file it finds in the /config/openvpn directory. Adding multiple ovpn files will not start multiple VPN connections.

## Example auth-user-pass option

`auth-user-pass credentials.conf`

## Example credentials.conf

```
username
password
```

## PUID/PGID

User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:

```
id <username>
```

# Issues

If you are having issues with this container please submit an issue on GitHub.
Please provide logs, docker version and other information that can simplify reproducing the issue.
Using the latest stable verison of Docker is always recommended. Support for older version is on a best-effort basis.

# Building the container yourself

To build this container, clone the repository and cd into it.

## Build it:

```
$ cd /repo/location/jackett
$ docker build -t jackett .
```

## Run it:

```
$ docker run --privileged  -d \
              -v /your/jackett/path/:/config/jackett \
              -v /your/openvpn/client.conf:/config/client.ovpn \
              -e "VPN_ENABLED=yes" \
              -e "LAN_NETWORK=192.168.1.0/24" \
              -e "NAME_SERVERS=8.8.8.8,8.8.4.4" \
              -p 8080:8080 \
              -p 8999:8999 \
              -p 8999:8999/udp \
              jackett
```

This will start a container as described in the "Run container from Docker registry" section.
