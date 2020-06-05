FROM debian:stable-slim
LABEL maintainer="arnulf.heimsbakk@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive \

    # Environment variables for user config
    MODE=master \
    MASTER_URL= \
    SHARED_SECRET=/etc/smokeping/slavesecrets.conf \
    SLAVE_NAME=slave\

    # Variables for siplifying this config
    APACHE_CONF_FILE=/etc/apache2/sites-available/000-default.conf \
    APACHE_SP_FILE=/etc/apache2/conf-available/smokeping.conf

RUN apt-get update; \
    apt-get install -y \
      dumb-init \
      libapache2-mod-fcgid \
      rsync \
      smokeping \
      ; \
    apt-get clean;

EXPOSE 80

VOLUME /etc/smokeping

ADD Targets /etc/smokeping/config.d/

RUN \
  # Apache config
  mv /usr/lib/cgi-bin/smokeping.cgi /usr/lib/cgi-bin/smokeping.fcgi; \
  sed -Ei "s|^(ScriptAlias).*|\1 /smokeping/smokeping.cgi /usr/lib/cgi-bin/smokeping.fcgi|g" $APACHE_SP_FILE; \
  sed -Ei "s|^(.*ErrorLog).*$|\1 /dev/stderr|g" ${APACHE_CONF_FILE}; \
  sed -Ei "s|^(.*CustomLog).*$|\1 /dev/stdout combined|g" ${APACHE_CONF_FILE}; \
  sed -i "29 i RedirectMatch '^/$' '/smokeping'" ${APACHE_CONF_FILE}; \
  # Smokeping configuration
  sed -i "/syslog/d" /etc/smokeping/config.d/General; \
  test -f ${SHARED_SECRET} || echo password > ${SHARED_SECRET}; \
  cp -arv /etc/smokeping /srv/; \
  sed -Ei "s|^(MASTER=).*$|\1${MASTER}|g" /etc/default/smokeping; \
  sed -Ei "s|^..(MASTER_URL=).*$|\1${MASTER_URL}|g" /etc/default/smokeping; \
  sed -Ei "s|^..(SHARED_SECRET=).*$|\1${SHARED_SECRET}|g" /etc/default/smokeping; \
  sed -Ei "s|^..(SLAVE_NAME=).*$|\1${SLAVE_NAME}|g" /etc/default/smokeping

CMD dumb-init -- sh -c 'rsync -ar --existing /srv/smokeping/ /etc/smokeping/ && /etc/init.d/smokeping start && apachectl -D FOREGROUND'
