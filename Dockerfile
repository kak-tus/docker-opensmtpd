FROM alpine:3.12 AS build

ENV \
  CONSUL_TEMPLATE_VERSION=0.25.1 \
  CONSUL_TEMPLATE_SHA256=58356ec125c85b9705dc7734ed4be8491bb4152d8a816fd0807aed5fbb128a7b

RUN \
  apk add --no-cache \
    curl \
    unzip \
  \
  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip

FROM golang:1.15.2-alpine3.12 AS build-go

RUN \
  apk add --no-cache \
    git

WORKDIR /go/nc

RUN go get github.com/poolpOrg/filter-rspamd

FROM alpine:3.12

ENV \
  CONSUL_HTTP_ADDR= \
  CONSUL_TOKEN= \
  DB_ADDR= \
  DB_PASSWORD= \
  DB_USER= \
  DKIM_ADDR= \
  LMTP_ADDR= \
  MAIL_SERVER_NAME= \
  RSPAMD_ADDR=

RUN \
  apk add --no-cache \
    ca-certificates \
    opensmtpd \
    postgresql-client

COPY --from=build /usr/local/bin/consul-template /usr/local/bin/consul-template
COPY templates /root/templates
COPY --from=build-go /go/bin/filter-rspamd /usr/local/bin/filter-rspamd

CMD ["/usr/local/bin/consul-template", "-config", "/root/templates/service.hcl"]
