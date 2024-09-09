ARG ARCH=
FROM ${ARCH}debian:bookworm
LABEL org.opencontainers.image.authors="Alessio (x-drum) Cassibba [zerodev.it]"

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends openssh-server borgbackup && \
    rm -rf /etc/ssh/ssh_host* && \
    mkdir -p /run/sshd && \
    adduser --quiet --home /home/borg --shell /bin/bash --uid 1000 --disabled-password --gecos "" borg && \
    usermod -p '*' borg

COPY files/motd /etc/motd
COPY files/sshd_config /etc/ssh/sshd_config
COPY files/entrypoint /

USER borg

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
CMD ["/usr/sbin/sshd", "-D","-e"]
