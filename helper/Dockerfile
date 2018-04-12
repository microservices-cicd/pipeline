FROM openshift/base-centos7

WORKDIR /bin

COPY pull.sh /bin/
COPY push.sh /bin/

RUN chmod +x /bin/pull.sh &&\
	  chmod +x /bin/pull.sh
  
RUN yum update -y --setopt=tsflags=nodocs && \
    yum install -y --setopt=tsflags=nodocs wget && \
    yum clean all  && \
    rm -rf /var/cache/yum

RUN wget "http://stedolan.github.io/jq/download/linux64/jq" && chmod 755 jq

# Define working directory.
WORKDIR /tmp

# Default command
ENTRYPOINT ["tail -f /dev/null"]
