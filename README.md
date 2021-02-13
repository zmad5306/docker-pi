# Docker PI

Docker compose files and notes for my PI.

## Certificates

### Certificate Authority

To generate new CA, **WARNING will required CA cert to be reinstalled on all devices**, this is should not normally be required.

```#!/bin/bash
openssl genpkey -algorithm RSA -out bitwarden.key -outform PEM -pkeyopt rsa_keygen_bits:2048
openssl req -new -key bitwarden.key -out bitwarden.csr
```

Create `pi4-01.ext` file in ~/certs:

```
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = pi4-01.local
DNS.2 = www.pi4-01.local
IP.1 = 192.168.254.249
```

### Certificate

To generate new certificate, ssh to pi and:

```#!/bin/bash
cd ~/certs
openssl x509 -req -in bitwarden.csr -CA self-signed-ca-cert.crt -CAkey private-ca.key -CAcreateserial -out bitwarden.crt -days 365 -sha256 -extfile bitwarden.ext
sudo mv pi4-01.crt pi4-01.key /etc/ssl/certs
```

## Services

These services run in docker and are installed with Docker Compose. Docker and Docker Compose must first be setup on the host.

* [Install docker](https://www.youtube.com/watch?v=eCJA1F72izc)
* [Install docker compose](https://devdojo.com/bobbyiliev/how-to-install-docker-and-docker-compose-on-raspberry-pi)

### pi-hole

Docker compose files for pi-hole. To run:

```#!/bin/bash
cd pi-hole
docker-compose up -d
````

### Setting admin password

```#!/bin/bash
docker exec -it pihole pihole -a -p ********
```

#### Update gravity

```#!/bin/bash
docker exec -it pihole pihole updateGravity
```

#### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/media/Storage/pi-hole-data/etc-pihole` | `/etc/pihole` | Data storeage for pi-hole, config, etc. |
| `/media/Storage/pi-hole-data/etc-dnsmasq.d` | `/etc/dnsmasq.d` | Dnsmasq data. |

Data for pi-hole is stored in the `/pi-hole-data` host directory.

### bit-warden

Docker compose files for Bitwarden. To run:

```#!/bin/bash
cd bit-warden
docker-compose up -d
```

#### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/media/Storage/bw-data` | `/data` | Bitwarden data files and database. |
| `/etc/ssl/certs` | `/ssl` | Maps the host's default ssl certificate directory into the container. [Certificate created for Bitwarden](https://github.com/dani-garcia/bitwarden_rs/wiki/Private-CA-and-self-signed-certs-that-work-with-Chrome) is stored here. |

#### Notes

* [Create Bitwarden SSL Certificate](https://github.com/dani-garcia/bitwarden_rs/wiki/Private-CA-and-self-signed-certs-that-work-with-Chrome)

### nextcloud

Docker compose files for Bitwarden. To run:

```#!/bin/bash
cd nextcloud
POSTGRES_PASSWORD=******** docker-compose up -d
```

#### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/media/Storage/nextcloud/db` | `/var/lib/postgresql/data` | Postgres database. |
| `/media/Storage/nextcloud/data` | `/data` | Main data store. |
| `/media/Storage/nextcloud/html` | `/var/www/html` | Web server content. |
| `/media/Storage/protonmail` | `/root` | Storage for Protonmail Bridge config. |

#### Utilities

Scan folders after bulk load of data: `docker exec --user www-data nextcloud php occ files:scan --all`

#### Protonmail Bridge

Used to integrate mail (SMTP) with Nextcloud.

First run needs to be started with `docker run --rm -it -v /media/Storage/protonmail:/root shenxn/protonmail-bridge:1.4.5-build init` this starts the CLI so the bridge can be confgured. See:

- [ProtonMail IMAP/SMTP Bridge Docker Container](https://github.com/shenxn/protonmail-bridge-docker)
- [Bridge CLI (command line interface) guide](https://protonmail.com/support/knowledge-base/bridge-cli-guide/)

To make the self-signed cert for the mail bridge work add `'mail_smtpstreamoptions' => array( 'ssl' => array( 'allow_self_signed' => true, 'verify_peer' => false, 'verify_peer_name' => false ) ),` to the Nextcloud config in `/media/Storage/nextcloud/html/config/config.php`, see [Additional settings Email configuration - SOLVED](https://help.nextcloud.com/t/additional-settings-email-configuration-solved/22070) for more info.

#### Notes

* [Install Nextcloud](https://www.youtube.com/watch?v=CHWHQFwxFcE)

### Emby

Docker compose files for Emby media server. To run:

```#!/bin/bash
cd emby
docker-compose up -d
```
#### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/media/Storage/emby/config` | `/config` | Emby Mediaserver configuration. |
| `/media/Storage/Video/Exercise` | `/data/video/exercise` | Exercise videos. |
| `/media/Storage/Video/KidsMovies` | `/data/video/kidsmovies` | Kids movies. |
| `/media/Storage/Video/Movies` | `/data/video/movies` | Movies. |
| `/media/Storage/Video/TV` | `/data/video/tv` | TV shows. |
| `/media/Storage/Video/YouTube` | `/data/video/youtube` | YouTube videos. |
| `/media/Storage/Music` | `/data/audio/music` | Music. |
| `/media/Storage/Podcasts` | `/data/audio/podcasts` | Podcasts. |

### Video Converter

To run:

```#!/bin/bash
cd video-converter
docker-compose up -d
```

#### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/media/Storage/Video/YouTube/Movies/NewPipe` | `/vids` | The volume to monitor. |

### Portainer

Docker compose files for Portainer docker managment. To run:

```#!/bin/bash
cd portainer
docker-compose up -d
```

#### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/var/run/docker.sock` | `/var/run/docker.sock` | Docker info to expose. |
| `/media/Storage/portainer` | `/data` | Portainer data and config. |

## Backups

Backup instructions for PI host.

### Mount backup drive

```#!/bin/bash
sudo mount -t auto /dev/sdb1 /media/Backup1
```

### Bitwarden

```#!/bin/bash
sudo rsync -rvh /media/Storage/bw-data /media/Backup1
```

### Music

```#!/bin/bash
sudo rsync -rvh /media/Storage/Music /media/Backup1
```

### Nextcloud

```#!/bin/bash
sudo rsync -rvh /media/Storage/nextcloud /media/Backup1
```

### Protonmail

```#!/bin/bash
sudo rsync -rvh /media/Storage/protonmail /media/Backup1
```

### Emby

```#!/bin/bash
sudo rsync -rvh /media/Storage/emby /media/Backup1
```

### Dropbox

```#!/bin/bash
sudo rsync -rvh /media/Storage/Dropbox /media/Backup1
```

### Podcasts

```#!/bin/bash
sudo rsync -rvh /media/Storage/Podcasts /media/Backup1
```

### Pi-Hole

```#!/bin/bash
sudo rsync -rvh /media/Storage/pi-hole-data /media/Backup1
```

### SAMBA

```#!/bin/bash
sudo cp /etc/samba/smb.conf /media/Backup1/samba/smb.conf
```

### Portainer

```#!/bin/bash
sudo rsync -rvh /media/Storage/portainer /media/Backup1
```
