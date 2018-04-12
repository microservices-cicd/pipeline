FROM openshift/base-centos7

WORKDIR /bin

COPY pull.sh /bin/
COPY push.sh /bin/

RUN chmod +x /bin/pull.sh &&\
	  chmod +x /bin/pull.sh
  
RUN wget "http://stedolan.github.io/jq/download/linux64/jq" && chmod 755 jq

# Define working directory.
WORKDIR /tmp

# Default command
CMD ["tail -f /dev/null"]
