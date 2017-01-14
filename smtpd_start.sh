#!/usr/bin/env sh

psql -h 172.18.0.1 -U mail mail -c "COPY ( SELECT DISTINCT substring( alias FROM '\@(.+)$') from dbmail_aliases ) TO STDOUT;" > /etc/smtpd/domains
psql -h 172.18.0.1 -U mail mail -c "COPY ( SELECT DISTINCT userid, '1000:1000:/root' FROM dbmail_users ) TO STDOUT;" > /etc/smtpd/virtual_users

smtpd -d
