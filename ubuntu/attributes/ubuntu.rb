default_unless[:ubuntu][:servers] = []

default[:ubuntu][:backup_log_dir] = "/var/log/backup.log"

default[:ubuntu][:logrotate][:syslog][:interval] = 'daily'
default[:ubuntu][:logrotate][:syslog][:keep_for] = 7
