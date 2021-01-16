# Docker PI

Docker compose files and notes for my PI.

## pi-hole

Docker compose files for pi-hole.

### Setting admin password

```#!/bin/bash
docker exec -it pihole pihole -a -p ********
```

### Volumes

Data for pi-hole is stored in the `/pi-hole-data` host directory.