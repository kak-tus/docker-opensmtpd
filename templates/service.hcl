max_stale = "2m"

template {
  source = "/root/templates/smtpd.conf.template"
  destination = "/etc/smtpd/smtpd.conf"
  perms = 0644
}

template {
  source = "/root/templates/mailname.template"
  destination = "/etc/smtpd/mailname"
  perms = 0644
}

template {
  source = "/root/templates/pgpass.template"
  destination = "/root/.pgpass"
  perms = 0600
}

template {
  source = "/root/templates/smtpd_start.sh.template"
  destination = "/usr/local/bin/smtpd_start.sh"
  perms = 0755
}

vault {
  renew_token = false
}

exec {
  command = "/usr/local/bin/smtpd_start.sh"
  splay = "60s"
}
