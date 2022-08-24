FROM amazonlinux:2

RUN yum install -y awscli jq shadow-utils util-linux sudo hostname \
    bind-utils procps-ng net-tools iproute \
    && yum clean all \
    && rm -rf /var/cache/yum

CMD ["sleep", "3600"]
