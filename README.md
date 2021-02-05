# Docker PI

Docker compose files and notes for my PI.

## pi-hole

Docker compose files for pi-hole. To run:

```#!/bin/bash
cd pi-hole
docker-compose up -d
````

### Setting admin password

```#!/bin/bash
docker exec -it pihole pihole -a -p ********
```

### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/pi-hole-data/etc-pihole` | `/etc/pihole` | Data storeage for pi-hole, config, etc. |
| `/pi-hole-data/etc-dnsmasq.d` | `/etc/dnsmasq.d` | Dnsmasq data. |

Data for pi-hole is stored in the `/pi-hole-data` host directory.

## bit-warden

Docker compose files for Bitwarden. To run:

```#!/bin/bash
cd bit-warden
docker-compose up -d
```

### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/media/Storage/bw-data` | `/data` | Bitwarden data files and database. |
| `/etc/ssl/certs` | `/ssl` | Maps the host's default ssl certificate directory into the container. [Certificate created for Bitwarden](https://github.com/dani-garcia/bitwarden_rs/wiki/Private-CA-and-self-signed-certs-that-work-with-Chrome) is stored here. |

## nextcloud

Docker compose files for Bitwarden. To run:

```#!/bin/bash
cd nextcloud
POSTGRES_PASSWORD=******** docker-compose up -d
```

### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/media/Storage/nextcloud/db` | `/var/lib/postgresql/data` | Postgres database. |
| `/media/Storage/nextcloud/data` | `/data` | Main data store. |
| `/media/Storage/nextcloud/html` | `/var/www/html` | Web server content. |

### Utilities

Scan folders after bulk load of data: `docker exec --user www-data nextcloud php occ files:scan --all`

### Protonmail Bridge

First run needs to be started with `docker run --rm -it -v /media/Storage/protonmail:/root shenxn/protonmail-bridge:1.4.5-build init` this starts the CLI so the bridge can be confgured. See:

- [ProtonMail IMAP/SMTP Bridge Docker Container](https://github.com/shenxn/protonmail-bridge-docker)
- [Bridge CLI (command line interface) guide](https://protonmail.com/support/knowledge-base/bridge-cli-guide/)

## Emby

Docker compose files for Emby media server. To run:

```#!/bin/bash
cd emby
docker-compose up -d
```
### Volumes

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

## ffmpeg

To run:

```#!/bin/bash
cd ffmpeg
docker-compose up -d
```

### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/media/Storage/protonmail` | `/root` | Configuration for Protonmail bridge. |

## Resources

* [Install docker](https://www.youtube.com/watch?v=eCJA1F72izc)
* [Install docker compose](https://devdojo.com/bobbyiliev/how-to-install-docker-and-docker-compose-on-raspberry-pi)
* [Create Bitwarden SSL Certificate](https://github.com/dani-garcia/bitwarden_rs/wiki/Private-CA-and-self-signed-certs-that-work-with-Chrome)
* [Install Nextcloud](https://www.youtube.com/watch?v=CHWHQFwxFcE)

## System

### Backups

#### Bitwarden

```#!/bin/bash
#backup
sudo tar -cvpzf /media/Storage/bitwarden-backup.tar.gz --one-file-system /media/Storage/bw-data

#restore
sudo tar -xvpzf /media/Storage/bitwarden-backup.tar.gz -C /media/Storage/bw-data --numeric-owner
```

#### Music

```#!/bin/bash
#backup
sudo tar -cvpzf /media/Storage/music-backup.tar.gz --one-file-system /media/Storage/Music

#restore
sudo tar -xvpzf /media/Storage/music-backup.tar.gz -C /media/Storage/Music --numeric-owner
```

#### Nextcloud

```#!/bin/bash
#backup
sudo tar -cvpzf /media/Storage/nextcloud-backup.tar.gz --one-file-system /media/Storage/nextcloud

#restore
sudo tar -xvpzf /media/Storage/nextcloud-backup.tar.gz -C /media/Storage/nextcloud --numeric-owner
```

#### Protonmail

```#!/bin/bash
#backup
sudo tar -cvpzf /media/Storage/protonmail-backup.tar.gz --one-file-system /media/Storage/protonmail

#restore
sudo tar -xvpzf /media/Storage/protonmail-backup.tar.gz -C /media/Storage/protonmail --numeric-owner
```

#### Emby

```#!/bin/bash
#backup
sudo tar -cvpzf /media/Storage/emby-backup.tar.gz --one-file-system /media/Storage/emby

#restore
sudo tar -xvpzf /media/Storage/emby-backup.tar.gz -C /media/Storage/emby --numeric-owner
```

#### Dropbox

```#!/bin/bash
#backup
sudo tar -cvpzf /media/Storage/dropbox-backup.tar.gz --one-file-system /media/Storage/Dropbox

#restore
sudo tar -xvpzf /media/Storage/dropbox-backup.tar.gz -C /media/Storage/Dropbox --numeric-owner
```

#### Podcasts

```#!/bin/bash
#backup
sudo tar -cvpzf /media/Storage/podcasts-backup.tar.gz --one-file-system /media/Storage/Podcasts

#restore
sudo tar -xvpzf /media/Storage/podcasts-backup.tar.gz -C /media/Storage/Podcasts --numeric-owner
```

#### System

```#!/bin/bash
#backup
sudo tar -cvpzf /media/Storage/system-backup.tar.gz --exclude=/media/* --one-file-system /

#restore
sudo tar -xvpzf /media/Storage/system-backup.tar.gz -C / --numeric-owner
```
