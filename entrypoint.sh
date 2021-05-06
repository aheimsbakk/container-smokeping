#!/bin/sh

rsync -ar /srv/etc_default/ /etc/default/
rsync -ar --ignore-existing /srv/etc_smokeping/ /etc/smokeping/
rsync -ar --ignore-existing /srv/var_lib_smokeping/ /var/lib/smokeping/

sed -Ei "s|^(MASTER=).*$|\1${MASTER}|g" /etc/default/smokeping; \
sed -Ei "s|^..(MASTER_URL=).*$|\1${MASTER_URL}|g" /etc/default/smokeping; \
sed -Ei "s|^..(SHARED_SECRET=).*$|\1${SHARED_SECRET}|g" /etc/default/smokeping; \
sed -Ei "s|^..(SLAVE_NAME=).*$|\1${SLAVE_NAME:-$(hostname -s)}|g" /etc/default/smokeping

exec dumb-init -- "$@"
