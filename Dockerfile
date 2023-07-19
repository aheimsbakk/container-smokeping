FROM aheimsbakk/base-debian:latest
LABEL org.opencontainers.image.authors="arnulf.heimsbakk@gmail.com"

# sysctl -w net.ipv4.ping_group_range="0 2147483647"
# /usr/bin/fping -C 20  -B1 -r1 -4 -i10 8.8.4.4 google.com youtube.com 8.8.8.8
# --cap-add net_admin --cap-add net_raw

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
      ca-certificates \
      dumb-init \
      libapache2-mod-fcgid \
      rsync \
      smokeping \
      ; \
    apt-get clean;

EXPOSE 80

VOLUME /etc/smokeping \
       /var/lib/smokeping

ADD Targets /etc/smokeping/config.d/
ADD entrypoint.sh /
ADD fcgid.conf /etc/apache2/mods-enabled/fcgid.conf

RUN /usr/sbin/update-ca-certificates
RUN \
  # Apache config
  mv /usr/lib/cgi-bin/smokeping.cgi /usr/lib/cgi-bin/smokeping.fcgi; \
  sed -Ei "s|^(ScriptAlias).*|\1 /smokeping/smokeping.cgi /usr/lib/cgi-bin/smokeping.fcgi|g" $APACHE_SP_FILE; \
  sed -Ei "s|^(.*ErrorLog).*$|\1 /dev/stderr|g" ${APACHE_CONF_FILE}; \
  sed -Ei "s|^(.*CustomLog).*$|\1 /dev/stdout combined|g" ${APACHE_CONF_FILE}; \
  sed -i "29 i RedirectMatch '^/$' '/smokeping'" ${APACHE_CONF_FILE}; \
  # Smokeping configuration
  sed -i "/syslog/d" /etc/smokeping/config.d/General; \
  echo "password" > "${SHARED_SECRET}"; \
  cp -arv /etc/default /srv/etc_default; \
  cp -arv /etc/smokeping /srv/etc_smokeping; \
  cp -arv /var/lib/smokeping /srv/var_lib_smokeping
  # chown smokeping:www-data /srv/var_lib_smokeping; \
  # chown smokeping:www-data /srv/etc_smokeping; \
  # chmod 2775 /srv/var_lib_smokeping

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "sh", "-c", "/etc/init.d/smokeping start && apachectl -D FOREGROUND" ]
