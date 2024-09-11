ARG ARCH=
FROM ${ARCH}alpine:3.17.0
LABEL org.opencontainers.image.authors="Alessio (x-drum) Cassibba [zerodev.it]"

RUN apk update && \
  apk add openssh py3-pip pkgconfig build-base python3-dev linux-headers libressl-dev lz4-dev acl-dev zstd-dev xxhash-dev && \
  adduser -h /home/borg -s /bin/sh -u 1000 -g "" -D borg && \
  passwd -u borg && \
  pip install borgbackup==1.4.0 borgmatic && \
  apk del pkgconfig build-base python3-dev linux-headers && \
  rm -rf /var/cache/apk/*

COPY files/motd /etc/motd
COPY files/sshd_config /etc/ssh/sshd_config
COPY files/entrypoint /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
CMD ["/usr/sbin/sshd", "-D","-e"]
