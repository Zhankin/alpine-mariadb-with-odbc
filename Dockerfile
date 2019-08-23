FROM yobasystems/alpine:3.8.1-amd64
LABEL maintainer "Toma Tasovac <ttasovac@humanistika.org>" architecture="AMD64/x86_64"
LABEL mariadb-version="10.2.15" alpine-version="3.8.1" build="03-dec-2018" container-build="$CI_COMMIT_SHA"

RUN apk add --no-cache mariadb mariadb-client pwgen bash nano unixodbc unixodbc-dev && \
    rm -f /var/cache/apk/*

ADD files/run.sh /scripts/run.sh
ADD files/lib/libmaodbc.so /lib/libmaodbc.so
ADD files/etc/odbcinst.ini /etc/odbcinst.ini
RUN mkdir /docker-entrypoint-initdb.d && \
    mkdir /scripts/pre-exec.d && \
    mkdir /scripts/pre-init.d && \
    chmod -R 755 /scripts

RUN apk add --update asterisk-cdr-mysql \
      asterisk \
      asterisk-sample-config \
&& rm -rf /usr/lib/asterisk/modules/*pjsip* \
&& asterisk -U asterisk \
&& sleep 5 \
&& pkill -9 asterisk \
&& pkill -9 astcanary \
&& sleep 2 \
&& rm -rf /var/run/asterisk/* \
&& mkdir -p /var/spool/asterisk/fax \
&& chown -R asterisk: /var/spool/asterisk/fax \
&& truncate -s 0 /var/log/asterisk/messages \
                 /var/log/asterisk/queue_log \
&&  rm -rf /var/cache/apk/* \
           /tmp/* \
           /var/tmp/*

EXPOSE 5060/udp 5060/tcp
VOLUME /var/lib/asterisk/sounds /var/lib/asterisk/keys /var/lib/asterisk/phoneprov /var/spool/asterisk /var/log/asterisk

ADD docker-entrypoint.sh /docker-entrypoint.sh

#ENTRYPOINT ["/docker-entrypoint.sh"]
ENTRYPOINT ["sh", "/scripts/run.sh"]
