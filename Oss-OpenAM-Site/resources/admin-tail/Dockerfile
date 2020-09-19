FROM alpine:latest

# Install bash, sudo, ps, awk
RUN apk add --no-cache --update \
        bash \
        sudo \
        procps \
        gawk \
 && rm -rf /tmp/* /var/tmp/*

# Set default shell to bash
RUN sed -e 's;/bin/ash$;/bin/bash;g' -i /etc/passwd
