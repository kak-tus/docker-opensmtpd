max_stale = "2m"

template {
  source = "/root/smtpd.conf.template"
  destination = "/etc/smtpd/smtpd.conf"
}

template {
  source = "/root/pgpass.template"
  destination = "/root/.pgpass"
  perms = 0600
}

exec {
  command = "/usr/local/bin/smtpd_start.sh"
  splay = "60s"
}
