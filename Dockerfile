FROM golang:1.17.5-alpine3.15 AS build-go

RUN \
  apk add --no-cache \
    git

WORKDIR /go/nc

RUN go install github.com/poolpOrg/filter-rspamd@v0.1.7

FROM alpine:3.15

RUN \
  apk add --no-cache \
    ca-certificates \
    opensmtpd

COPY --from=build-go /go/bin/filter-rspamd /usr/lib/opensmtpd/filter-rspamd

CMD ["/usr/sbin/smtpd", "-d"]
