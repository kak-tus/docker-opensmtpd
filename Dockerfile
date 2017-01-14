FROM alpine:3.4

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=
ENV VAULT_ADDR=
ENV VAULT_TOKEN=

COPY consul-template_0.18.0-rc2_SHA256SUMS /usr/local/bin/consul-template_0.18.0-rc2_SHA256SUMS

RUN \
  apk add --update-cache curl unzip opensmtpd postgresql-client \

  && cd /usr/local/bin \

  && curl -L https://releases.hashicorp.com/consul-template/0.18.0-rc2/consul-template_0.18.0-rc2_linux_amd64.zip -o consul-template_0.18.0-rc2_linux_amd64.zip \
  && sha256sum -c consul-template_0.18.0-rc2_SHA256SUMS \
  && unzip consul-template_0.18.0-rc2_linux_amd64.zip \
  && rm consul-template_0.18.0-rc2_linux_amd64.zip consul-template_0.18.0-rc2_SHA256SUMS \

  && apk del curl unzip && rm -rf /var/cache/apk/*

COPY smtpd.hcl /etc/smtpd.hcl
COPY smtpd.conf.template /root/smtpd.conf.template
COPY smtpd_start.sh /usr/local/bin/smtpd_start.sh
COPY pgpass.template /root/pgpass.template

CMD consul-template -config /etc/smtpd.hcl
