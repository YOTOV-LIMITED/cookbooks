default[:postfix][:mail_type]  = "client"
default[:postfix][:myhostname] = fqdn
default[:postfix][:mydomain]   = domain
default[:postfix][:other_domains] = ''
default[:postfix][:myorigin]   = "$myhostname"
default[:postfix][:relayhost]  = ""
default[:postfix][:mail_relay_networks] = "127.0.0.0/8"

default[:postfix][:smtp_sasl_auth_enable] = "no"
default[:postfix][:smtp_sasl_password_maps]    = "hash:/etc/postfix/sasl_passwd"
default[:postfix][:smtp_sasl_security_options] = "noanonymous"
default[:postfix][:smtp_tls_security_level] = ""
default[:postfix][:header_size_limit] = 4096000
default[:postfix][:smtp_tls_cafile] = "/etc/postfix/cacert.pem"
default[:postfix][:smtp_use_tls]    = "yes"
default[:postfix][:smtp_sasl_user_name] = ""
default[:postfix][:smtp_sasl_passwd]    = ""

default[:postfix][:inet_interfaces] = 'loopback-only'
