FROM debian

RUN set -x \
    && echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections \
    && echo "locales locales/default_environment_locale select en_US.UTF-8" | debconf-set-selections \
    && apt-get -q update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
        curl \
        build-essential \
        libncurses-dev \
        rsync \
        unzip \
        bc \
        gnupg \
        python \
        libc6-i386 \
        cpio \
        locales \
        git-core

COPY rootfs /tmp/rootfs

ENV BUILDROOT_BUCKET buildroot.uclibc.org
ENV BUILDROOT_VERSION 2016.02
ENV BUILDROOT_SHA1 ede6edac357d6c75518ddee471cfd945570a565a
RUN set -x \
    && curl -fSL "http://${BUILDROOT_BUCKET}/downloads/buildroot-$BUILDROOT_VERSION.tar.gz" -o buildroot.tgz \
    && echo "${BUILDROOT_SHA1} *buildroot.tgz" | sha1sum -c - \
    && tar -xzvf buildroot.tgz \
    && mv buildroot-$BUILDROOT_VERSION /tmp/buildroot \
    && rm -rf buildroot.tgz

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.11.0
ENV DOCKER_SHA256 87331b3b75d32d3de5d507db9a19a24dd30ff9b2eb6a5a9bdfaba954da15e16b
RUN set -x \
    && curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz" -o docker.tgz \
    && echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
    && tar -xzvf docker.tgz \
    && mv docker/* /usr/local/bin/ \
    && rmdir docker \
    && rm docker.tgz \
    && docker -v

RUN ln -s /tmp/config/buildroot /tmp/buildroot/.config

WORKDIR /tmp/buildroot
