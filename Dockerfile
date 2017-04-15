FROM alpine:edge

ENV CONSUL_TEMPLATE_VERSION=0.16.0
ENV CONSUL_TEMPLATE_SHA256=064b0b492bb7ca3663811d297436a4bbf3226de706d2b76adade7021cd22e156

RUN \
  echo "@testing http://nl.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk add --no-cache opensmtpd postgresql-client rspamd-client@testing \

  && apk add --no-cache --virtual .build-deps curl unzip \

  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

  # Delete temporary disable due to @testing warning
  # Try enable in alpine:3.6
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
