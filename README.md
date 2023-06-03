# Docker PI

Docker compose files and notes for my PI.

## Server 

### Certificates

#### Annual Renewal

To generate new certificate (required annually):

##### Nextcloud

```#!/bin/bash
openssl x509 -req -in nextcloud.csr -CA self-signed-ca-cert.crt -CAkey private-ca.key -CAcreateserial -out nextcloud.crt -days 365 -sha256 -extfile nextcloud.ext
sudo cp nextcloud.crt /etc/ssl/certs
```

##### Bitwarden

```#!/bin/bash
openssl x509 -req -in bitwarden.csr -CA self-signed-ca-cert.crt -CAkey private-ca.key -CAcreateserial -out bitwarden.crt -days 365 -sha256 -extfile bitwarden.ext
sudo cp bitwarden.crt /etc/ssl/certs
```

##### Pihole

```#!/bin/bash
openssl x509 -req -in pihole.csr -CA self-signed-ca-cert.crt -CAkey private-ca.key -CAcreateserial -out pihole.crt -days 365 -sha256 -extfile pihole.ext
sudo cp pihole.crt /etc/ssl/certs
```

##### Emby

```#!/bin/bash
openssl x509 -req -in emby.csr -CA self-signed-ca-cert.crt -CAkey private-ca.key -CAcreateserial -out emby.crt -days 365 -sha256 -extfile emby.ext
sudo cp pihole.crt /etc/ssl/certs
```

#### Generate Certificate for New Service

Cerate `<service name>.ext` file by copying one from another service and modifying.

```#!/bin/bash
openssl genrsa -out <service name>.key 2048
openssl req -key <service name>.key -new -out <service name>.csr
openssl x509 -req -in <service name>.csr -CA self-signed-ca-cert.crt -CAkey private-ca.key -CAcreateserial -out <service name>.crt -days 365 -sha256 -extfile <service name>.ext
sudo cp <service name>.crt /etc/ssl/certs
```

### Backups

#### Storage

Backup instructions for PI host.

```#!/bin/bash
sudo mount -t auto /dev/sdb /media/Backup
sudo rsync -rvh /media/Storage/ /media/Backup/backups/server-01/
```

#### Bitwarden

##### Cloud Backup File

On Server

```#!/bin/bash
cd /media/Storage
sudo tar cz bw-data | openssl enc -aes-256-cbc -e > bw-data.tar.gz.enc
```

On workstation

```#!/bin/bash
scp <user>@<server ip>:/media/Storage/bw-data.tar.gz.enc .
```

Decrypt

```#!/bin/bash
openssl enc -aes-256-cbc -d -in bw-data.tar.gz.enc | tar xz
```

#### Certificate Authority

```#!/bin/bash
cd ~
sudo tar cz certs | openssl enc -aes-256-cbc -e > ca.tar.gz.enc
```

On workstation

```#!/bin/bash
scp <user>@<server ip>:~/ca.tar.gz.enc .
```

Decrypt

```#!/bin/bash
openssl enc -aes-256-cbc -d -in ca.tar.gz.enc | tar xz
```

### SAMBA

```#!/bin/bash
sudo apt update
sudo apt install samba
sudo nano /etc/samba/smb.conf
sudo service smbd restart
sudo ufw allow samba
sudo smbpasswd -a username
```

#### Share Config

```
[Dropbox]
    comment = Dropbox on Storage
    path = /media/Storage/Dropbox/
    read only = no
    browsable = yes
    valid users = <a user>

[YouTube]
    comment = YouTube on Storage
    path = /media/Storage/Video/YouTube
    read only = no
    browsable = yes
    valid users = <a user>

[Music]
    comment = Music on Storage
    path = /media/Storage/Music
    read only = yes
    browsable = yes
    valid users = <a user>
```

## Docker Services

These services run in docker and are installed with Docker Compose. Docker and Docker Compose must first be setup on the host.

### pi-hole

Setup Nginx config:

```#!/bin/bash
cd nextcloud
sudo cp nginx.conf /media/Storage/pihole/nginx/
```

Docker compose files for pi-hole. To run:

```#!/bin/bash
cd pi-hole
docker-compose up -d
```

#### Setting admin password

```#!/bin/bash
docker exec -it pihole pihole -a -p ********
```

#### Update gravity

```#!/bin/bash
docker exec -it pihole pihole updateGravity
```

#### Schedule update gravity with cron

Execute `sudo crontab -e` to open cron editor and add:

```#!/bin/bash
# Update pihole gravity every Sunday at midnight
0 0 * * 0 /usr/bin/docker exec -it pihole pihole updateGravity
```

### bit-warden

Docker compose files for Bitwarden. To run:

```#!/bin/bash
cd bit-warden
docker-compose up -d
```

### nextcloud

Docker compose files for Nextcloud. 

Setup Nginx config:

```#!/bin/bash
cd nextcloud
sudo cp nginx.conf /media/Storage/nextcloud/nginx/
```

To run:

```#!/bin/bash
cd nextcloud
sudo chown -R www-data:www-data /media/Storage/nextcloud
POSTGRES_PASSWORD=******** docker-compose up -d
```

#### Utilities

Scan folders after bulk load of data: `docker exec --user www-data nextcloud php occ files:scan --all`

#### Protonmail Bridge

Used to integrate mail (SMTP) with Nextcloud.

First run needs to be started with `docker run --rm -it -v /media/Storage/protonmail:/root shenxn/protonmail-bridge:1.4.5-build init` this starts the CLI so the bridge can be confgured. See:

- [ProtonMail IMAP/SMTP Bridge Docker Container](https://github.com/shenxn/protonmail-bridge-docker)
- [Bridge CLI (command line interface) guide](https://protonmail.com/support/knowledge-base/bridge-cli-guide/)

To make the self-signed cert for the mail bridge work add 

```
'mail_smtpstreamoptions' => 
  array( 
    'ssl' => array( 
      'allow_self_signed' => true, 
      'verify_peer' => false, 
      'verify_peer_name' => false 
      ) 
  ),
```

to the Nextcloud config in `/media/Storage/nextcloud/html/config/config.php`

see [Additional settings Email configuration - SOLVED](https://help.nextcloud.com/t/additional-settings-email-configuration-solved/22070) for more info.

#### Nginx Reverse Proxy for HTTPS

Make the following configs in `/media/Storage/nextcloud/html/config/config.php`. More details can be found in: [BobyMCbobs/nextcloud-docker-nginx-reverse-proxy](https://github.com/BobyMCbobs/nextcloud-docker-nginx-reverse-proxy).

```
'overwritehost' => '<server address>:8082',
  'overwriteprotocol' => 'https',
  'trusted_proxies' =>
  array (
    0 => 'nginx-proxy'
  ),
```

Change trusted domains:

  ```
'trusted_domains' => 
  array (
    0 => '<server adddress>:8082',
    1 => 'nginx-proxy',
    2 => '<server address>'
  ),
```

### Emby

Create user for emby and grant access. Add `pi` user to `emby` group so SMB can still write.

```#!/bin/bash
sudo useradd -m -G emby embyuser
sudo chgrp emby /media/Storage/Video/YouTube/Movies/NewPipe/
sudo chmod g+rwx /media/Storage/Video/YouTube/Movies/NewPipe/
sudo usermod -g emby pi
```

Find `emby`'s `UID` and `GID` by running `cat /etc/passwd`. Use `UID` of the `embyuser` user and `GID` of `emby` group.

Docker compose files for Emby media server. To run:

```#!/bin/bash
cd emby
USER_ID=**** GROUP_ID=**** docker-compose up -d
```

### Portainer

Docker compose files for Portainer docker managment. To run:

```#!/bin/bash
cd portainer
docker-compose up -d
```
