FROM alpine:3.8 AS build

ENV \
  CONSUL_TEMPLATE_VERSION=0.19.4 \
  CONSUL_TEMPLATE_SHA256=5f70a7fb626ea8c332487c491924e0a2d594637de709e5b430ecffc83088abc0 \
  \
  RTTFIX_VERSION=0.1 \
  RTTFIX_SHA256=349b309c8b4ba0afe3acf7a0b0173f9e68fffc0f93bad4b3087735bd094dea0d

RUN \
  apk add --no-cache --virtual .build-deps \
    curl \
    unzip \
  \
  && cd /usr/local/bin \
  && curl -L https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -o consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && echo -n "$CONSUL_TEMPLATE_SHA256  consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip" | sha256sum -c - \
  && unzip consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip \
  \
  && cd /usr/local/bin \
  && curl -L https://github.com/kak-tus/rttfix/releases/download/$RTTFIX_VERSION/rttfix -o rttfix \
  && echo -n "$RTTFIX_SHA256  rttfix" | sha256sum -c - \
  && chmod +x rttfix

FROM golang:1.11.1-alpine3.8 AS build-go

WORKDIR /go/src/github.com/kak-tus/docker-opensmtpd/nc

COPY nc/main.go .

RUN go install

FROM alpine:3.7

ENV \
  CONSUL_HTTP_ADDR= \
  CONSUL_TOKEN= \
  VAULT_ADDR= \
  VAULT_TOKEN=

RUN \
  apk add --no-cache \
    ca-certificates \
    opensmtpd \
    postgresql-client \
    rspamd-client

COPY --from=build /usr/local/bin/rttfix /usr/local/bin/rttfix
COPY --from=build /usr/local/bin/consul-template /usr/local/bin/consul-template
COPY templates /root/templates
COPY --from=build-go /go/bin/nc /usr/local/bin/nc

CMD ["/usr/local/bin/consul-template", "-config", "/root/templates/service.hcl"]
