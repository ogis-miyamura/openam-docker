FROM alpine:latest

RUN apk add --no-cache --update \
        sudo \
        procps \
        bash \
        gawk \
 && rm -rf /tmp/* /var/tmp/*

RUN sed -e 's;/bin/ash$;/bin/bash;g' -i /etc/passwd

# RUN cat <<EOF > ~/.bashrc \n\
# PS1="\[\e[1;32m\]\u@\h:\[\e[0m\]\w\[\e[1;32m\]$ \[\e[0m\]" \n\
# EOF

# RUN cat <<EOF >> ~/.profile \n\
# if [ "\${SHELL}x" = "/bin/bashx" ]; then \n\
#   if [ -f "\${HOME}/.bashrc" ]; then \n\
#     . "\${HOME}/.bashrc" \
#   fi \n\
# fi \n\
# EOF
