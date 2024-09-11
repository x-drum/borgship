FROM debian:bookworm
LABEL org.opencontainers.image.authors="Alessio (x-drum) Cassibba [zerodev.it]"

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install --no-install-recommends openssh-server ca-certificates wget cron pip pkg-config build-essential python3-dev libssl-dev libacl1-dev liblz4-dev libzstd-dev libxxhash-dev && \
    rm -rf /etc/ssh/ssh_host* && \
    mkdir -p /run/sshd && \
    adduser --quiet --home /home/borg --shell /bin/bash --uid 1000 --disabled-password --gecos "" borg && \
    usermod -p '*' borg && \
    python3 -m pip install borgbackup==2.0.0b10 borgmatic --break-system-packages && \
    apt purge -y pip pkg-config build-essential python3-dev libssl-dev libacl1-dev liblz4-dev libzstd-dev libxxhash-dev && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

COPY files/motd /etc/motd
COPY files/sshd_config /etc/ssh/sshd_config
COPY files/entrypoint /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
CMD ["/usr/sbin/sshd", "-D","-e"]
