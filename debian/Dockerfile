FROM debian:sid

ENV CONSUL_HTTP_ADDR=
ENV CONSUL_TOKEN=
ENV VAULT_ADDR=
ENV VAULT_TOKEN=

COPY consul-template_0.16.0_SHA256SUMS /usr/local/bin/consul-template_0.16.0_SHA256SUMS

RUN \
  apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  curl unzip postgresql-client ca-certificates wget gnupg netcat \

  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends \
  --no-install-suggests -y -o Dpkg::Options::="--force-confdef" opensmtpd \

  && cd /usr/local/bin \

  && curl -L https://releases.hashicorp.com/consul-template/0.16.0/consul-template_0.16.0_linux_amd64.zip -o consul-template_0.16.0_linux_amd64.zip \
  && sha256sum -c consul-template_0.16.0_SHA256SUMS \
  && unzip consul-template_0.16.0_linux_amd64.zip \
  && rm consul-template_0.16.0_linux_amd64.zip consul-template_0.16.0_SHA256SUMS \

  && mkdir -p /etc/smtpd \
  && touch /etc/smtpd/smtpd.conf \
  && rm /etc/smtpd.conf \
  && ln -s /etc/smtpd/smtpd.conf /etc/smtpd.conf \

  && wget -O- https://rspamd.com/apt-stable/gpg.key | apt-key add - \
  && echo "deb http://rspamd.com/apt-stable/ sid main" > /etc/apt/sources.list.d/rspamd.list \
  && apt-get update \
  && apt-get install --no-install-recommends --no-install-suggests -y \
  rspamd \
  && chown 102 /var/spool/smtpd/purge \

  && apt-get purge -y --auto-remove curl unzip wget \ 
  && rm -rf /var/lib/apt/lists/*

COPY smtpd.hcl /etc/smtpd.hcl
COPY smtpd.conf.template /root/smtpd.conf.template
COPY smtpd_start.sh.template /root/smtpd_start.sh.template
COPY pgpass.template /root/pgpass.template
COPY rspamd.sh.template /root/rspamd.sh.template

CMD consul-template -config /etc/smtpd.hcl
