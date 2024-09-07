ARG ARCH=
FROM ${ARCH}alpine:3.20.2
LABEL org.opencontainers.image.authors="Alessio (x-drum) Cassibba [zerodev.it]"

RUN apk update && \
  apk add openssh borgbackup && \
  adduser -h /home/borg -s /bin/sh -u 1000 -g "" -D borg && \
  passwd -u borg


COPY files/motd /etc/motd
COPY files/sshd_config /etc/ssh/sshd_config
COPY files/entrypoint /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
CMD ["/usr/sbin/sshd", "-D","-e"]
