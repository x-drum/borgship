ARG ARCH=
FROM ${ARCH}alpine:3.17.0
LABEL org.opencontainers.image.authors="Alessio (x-drum) Cassibba [zerodev.it]"

RUN apk update && \
  apk add openssh borgbackup borgmatic && \
  adduser -h /home/borg -s /bin/sh -u 1000 -g "" -D borg && \
  passwd -u borg && \
  rm -rf /var/cache/apk/*


COPY files/motd /etc/motd
COPY files/sshd_config /etc/ssh/sshd_config
COPY files/entrypoint /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
CMD ["/usr/sbin/sshd", "-D","-e"]
