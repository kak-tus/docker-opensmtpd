FROM alpine:3.6

ENV CONSUL_TEMPLATE_VERSION=0.18.5
ENV CONSUL_TEMPLATE_SHA256=b0cd6e821d6150c9a0166681072c12e906ed549ef4588f73ed58c9d834295cd2

RUN \
  echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \

  && apk add --no-cache \
    opensmtpd \
    postgresql-client \
    rspamd-client@testing \

  && apk add --no-cache --virtual .build-deps \
    curl \
    unzip \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

  # Delete temporary disabled due to @testing warning
  # Try enable in alpine:3.7
  # && apk del .build-deps

COPY smtpd.hcl /etc/smtpd.hcl
COPY smtpd.conf.template /root/smtpd.conf.template
COPY smtpd_start.sh.template /root/smtpd_start.sh.template
COPY pgpass.template /root/pgpass.template
COPY rspamd.sh.template /root/rspamd.sh.template

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=
ENV VAULT_ADDR=
ENV VAULT_TOKEN=

CMD ["/usr/local/bin/consul-template", "-config", "/etc/smtpd.hcl"]
