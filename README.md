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

## Plex

Docker compose files for Plex Mediaserver. To run:

```#!/bin/bash
cd plex
docker-compose up -d
```

### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/media/Storage/plex/config` | `/config` | Plex Mediaserver configuration. |
| `/media/Storage/Video/Exercise` | `/data/video/exercise` | Exercise videos. |
| `/media/Storage/Video/KidsMovies` | `/data/video/kidsmovies` | Kids movies. |
| `/media/Storage/Video/Movies` | `/data/video/movies` | Movies. |
| `/media/Storage/Video/TV` | `/data/video/tv` | TV shows. |
| `/media/Storage/Video/YouTube` | `/data/video/youtube` | YouTube videos. |
| `/media/Storage/Zach/Music` | `/data/audio/music` | Music. |
| `/media/Storage/Zach/Podcasts` | `/data/audio/podcasts` | Podcasts. |

## Emby

Docker compose files for Emby media server. To run:
```#!/bin/bash
cd emby
docker-compose up -d
```
### Volumes

| Path on Host | Path on Container | Description |
| --- | --- | --- |
| `/media/Storage/emby/config` | `/config` | Plex Mediaserver configuration. |
| `/media/Storage/Video/Exercise` | `/data/video/exercise` | Exercise videos. |
| `/media/Storage/Video/KidsMovies` | `/data/video/kidsmovies` | Kids movies. |
| `/media/Storage/Video/Movies` | `/data/video/movies` | Movies. |
| `/media/Storage/Video/TV` | `/data/video/tv` | TV shows. |
| `/media/Storage/Video/YouTube` | `/data/video/youtube` | YouTube videos. |
| `/media/Storage/Zach/Music` | `/data/audio/music` | Music. |
| `/media/Storage/Zach/Podcasts` | `/data/audio/podcasts` | Podcasts. |

## Resources

* [Install docker](https://www.youtube.com/watch?v=eCJA1F72izc)
* [Install docker compose](https://devdojo.com/bobbyiliev/how-to-install-docker-and-docker-compose-on-raspberry-pi)
* [Create Bitwarden SSL Certificate](https://github.com/dani-garcia/bitwarden_rs/wiki/Private-CA-and-self-signed-certs-that-work-with-Chrome)
* [Install Nextcloud](https://www.youtube.com/watch?v=CHWHQFwxFcE)
