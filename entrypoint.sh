#!/bin/sh

sed -Ei "s|^(MASTER=).*$|\1${MASTER}|g" /etc/default/smokeping; \
sed -Ei "s|^..(MASTER_URL=).*$|\1${MASTER_URL}|g" /etc/default/smokeping; \
sed -Ei "s|^..(SHARED_SECRET=).*$|\1${SHARED_SECRET}|g" /etc/default/smokeping; \
sed -Ei "s|^..(SLAVE_NAME=).*$|\1${SLAVE_NAME}|g" /etc/default/smokeping

rsync -ar --ignore-existing /srv/smokeping/ /etc/smokeping/

exec dumb-init -- "$@"
