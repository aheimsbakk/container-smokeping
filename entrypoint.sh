#!/bin/sh

rsync -ar /srv/etc_default/ /etc/default/
rsync -ar --ignore-existing /srv/etc_smokeping/ /etc/smokeping/
rsync -ar --ignore-existing /srv/var_lib_smokeping/ /var/lib/smokeping/

echo "${SHARED_SECRET}" > /etc/smokeping/slavesecrets.conf
chown smokeping:www-data /etc/smokeping/slavesecrets.conf
chmod 640 /etc/smokeping/slavesecrets.conf

sed -Ei "s|^(MODE=).*$|\1${MODE}|g" /etc/default/smokeping; \
sed -Ei "s|^..(MASTER_URL=).*$|\1${MASTER_URL}|g" /etc/default/smokeping; \
sed -Ei "s|^..(SHARED_SECRET=.*)$|\1|g" /etc/default/smokeping; \
sed -Ei "s|^..(SLAVE_NAME=).*$|\1${SLAVE_NAME:-$(hostname -s)}|g" /etc/default/smokeping

exec dumb-init -- "$@"