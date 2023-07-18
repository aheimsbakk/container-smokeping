# smokeping

Container for running [Smokeping](https://oss.oetiker.ch/smokeping/). Based on [Debian stable container](https://hub.docker.com/_/debian). Original source: https://github.com/aheimsbakk/container-smokeping.

Used for smokeping service running on service klynge.

## Tags

* `latest` ([Dockerfiler](//github.com/aheimsbakk/smokeping/blob/master/Dockerfile))

## Build

* Every week.

## Environment variables

* `MODE`

    Mode can be `master` or `slave`, default `master`.

* `MASTER_URL`

    URL to master node, default `""`.

* `SHARED_SECRET`

    File with slave secrets, default `/etc/smokeping/slavesecrets.conf`.

* `SLAVE_NAME`

    Name of slave node, default `""`.

## Exposed ports

* `80`

## Volumes

For persistence.

* `/etc/smokeping`

    Configuration included on run. Directory be populated with default configuration on first run.

* `/var/lib/smokeping`

    Smokeping [RRD](https://en.wikipedia.org/wiki/RRDtool) data files.

## How to use this container

```
docker run -d \
  -v /srv/smokeping/config:/etc/smokeping \
  -v /srv/smokeping/data:/var/lib/smokeping \
  -p 80:80 \
  --name smokeping \
  --cap-add net_admin \
  --cap-add net_raw \
  aheimsbakk/smokeping
```

<!---
# vim: set spell spelllang=en:
-->
