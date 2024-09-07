![Borgship logo](https://raw.githubusercontent.com/x-drum/borgship/main/files/borgship-banner.png "borgship")

# A Borgbackup SSH (central) repository running on docker

A simple and easy to use Borg SSH (central) repository - We will add your backups to our own repo.

# Docker images and tags

Docker builds linked to official [Debian](https://hub.docker.com/_/debian/) and [Alpine](https://hub.docker.com/_/alpine/) repository images with upstream [Borgbackup](https://www.borgbackup.org/) binaries.

**Github Repository:**  [https://github.com/x-drum/borgship](https://github.com/x-drum/borgship)

**Docker Hub:**  [https://hub.docker.com/r/xdrum/borgship/tags](https://hub.docker.com/r/xdrum/borgship)

**Docker Hub Tags:**  [https://hub.docker.com/r/xdrum/borgship/tags](https://hub.docker.com/r/xdrum/borgship/tags)


| Tag           | Distribution release | Borgbackup release |
|---------------|----------------------|--------------------|
|main           | debian 12 (bookworm) | 2.0.0b9            |
|1.4.0-bookworm | debian 12 (bookworm) | 1.4.0              |
|1.2.4-bookworm | debian 12 (bookworm) | 1.2.4              |
|1.2.8-alpine   | alpine 3.2.0         | 1.2.8              |

# Usage

- Define server and ports (multiple server instances are possible)
- Mount your volumes for: `backup`
- Mount your user's authorized key files (e.g: `./id_rsa.pub:/home/borg/.ssh/authorized_keys:ro`)
- Mount your server OpenSSH host keys for consistent server fingerprints (e.g: `./ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key`, `./ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key`)  `[OPTIONAL]`
- Override OpenSSH server sshd_config file (e.g: `./config/server/sshd_config:/etc/ssh/sshd_config`) `[OPTIONAL]`

# Notes
## Important
- OpenSSH host keys will be generated automatically at first run if missing. To avoid MITM warnings when connecting the preferred method is to override them, see ***examples*** and ***misc*** sections below.
- Password login is **not supported**, you **MUST** provide at least one public key via ~/.ssh/authorized_keys file:
```
docker run \
    -p 3333:22 \
    -v ./backups:/home/borg/backups \
    -v ./id_rsa.pub:/home/borg/.ssh/authorized_keys:ro \
    -d xdrum/borgship
```
## Additional Notes
- User 'borg' will now be able to login via SSH and upload backups to directory `backups` located inside it's home.
- At this time borg user has hardcoded `UID 1000` and `GID 1000`. Keep it in mind and check host filesystem permissions and ownership.
- Some image will ship [Borgbackup](https://www.borgbackup.org/) binaries offered via the native package manager however latest official builds are provided as binaries from upstream (if any).
- OpenSSH ECDSA host keys are disabled by default (However it's possibile to override this mounting keys and overriding sshd_config file).

# Examples

## Running a simple container (useless due to missing authentication see Notes above)

```
docker run -p 3333:22 -d xdrum/borgship 
```

User "foo" with password "pass" can login with sftp and upload files to a folder called "upload". No mounted directories or custom UID/GID. Later you can inspect the files and use `--volumes-from` to mount them somewhere else (or see next example).

## Running a simple container (with pubkey authentication)

```
docker run \
    -p 3333:22 \
    -v ./backups:/home/borg/backups \
    -v ./id_rsa.pub:/home/borg/.ssh/authorized_keys:ro \
    -d xdrum/borgship
```

## Running a container with full override (preferred method)

```
docker run \
    -p 3333:22 \
    -v ./backups:/home/borg/backups \
    -v ./id_rsa.pub:/home/borg/.ssh/authorized_keys:ro \
    -v ./ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key \
    -v ./ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key \
    -v ./config/server/sshd_config:/etc/ssh/sshd_config
    -d xdrum/borgship
```

## Running using docker-compose (full example for preferred method)

```
services:
  borgship1:
      image: xdrum/borgship
      container_name: borgship1
      volumes:
          - ./backups:/home/borg/backups
          - ./id_rsa.pub:/home/borg/.ssh/authorized_keys:ro
          - ./sshd_config:/etc/ssh/sshd_config
          - ./ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key
          - ./ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key
      ports:
          - "3333:22"
      network_mode: bridge
```
## Running multiple containers using docker-compose (full example for preferred method)

```
services:
  borgship1:
      image: xdrum/borgship
      container_name: borgship1
      volumes:
          - ./backups:/home/borg/backups
          - ./id_rsa.pub:/home/borg/.ssh/authorized_keys:ro
          - ./sshd_config:/etc/ssh/sshd_config
          - ./ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key
          - ./ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key
      ports:
          - "3333:22"
      network_mode: bridge

  borgship2:
      image: xdrum/borgship
      container_name: borgship2
      volumes:
          - ./backups-server2:/home/borg/backups
          - ./id_rsa-server2.pub:/home/borg/.ssh/authorized_keys:ro
          - ./sshd_config:/etc/ssh/sshd_config
          - ./ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key
          - ./ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key
      ports:
          - "3334:22"
      network_mode: bridge

    ## [ .. cut .. ]
```

# Misc.

This container will generate new SSH host keys at first run. To avoid that your users get a MITM warning when you recreate your container (and the host keys changes), you can mount your own host keys.


## Generate your own persistent OpenSSH server host keys (Recommended method)
```
ssh-keygen -t rsa -b 4096 -f ./ssh_host_rsa_key -N "" < /dev/null
ssh-keygen -t ed25519 -f ./ssh_host_ed25519_key -N "" < /dev/null
```
