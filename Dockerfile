FROM rhel7:7.4-120

LABEL summary="RHMAP Docker image used for data caching" \
      description="RHMAP Docker image used for data caching" \
      io.k8s.description="RHMAP Docker image used for data caching" \
      io.k8s.display-name="RHMAP 4.5 Memcached" \
      #io.openshift.expose-services="11211:memcached" \
      io.openshift.tags="rhmap45,memcached"

# Labels consumed by Red Hat build service
LABEL com.redhat.component="rhmap-memcached-docker" \
      architecture="x86_64" \
      name="rhmap45/memcached" \
      version="1.4.15" \
      release="28"

#EXPOSE 11211

# Create user for memcached that has known UID
# We need to do this before installing the RPMs which would create user with random UID
RUN getent group  memcached &> /dev/null || groupadd -r memcached &> /dev/null && \
    getent passwd memcached &> /dev/null || useradd -u 1001 -r -g memcached -d /run/memcached -s /sbin/nologin \
           -c 'Memcached daemon' memcached &> /dev/null

RUN INSTALL_PKGS='memcached nmap-ncat' && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    ln -sf /usr/share/zoneinfo/UTC /etc/localtime

USER memcached

ENTRYPOINT ["memcached"]
CMD ["-m", "512", "-vv"]