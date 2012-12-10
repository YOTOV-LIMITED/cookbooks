set_unless[:redis][:version]  = "2.4.17"
set_unless[:redis][:source_url] = "http://redis.googlecode.com/files/redis-#{redis[:version]}"
set_unless[:redis][:bin_path] = "/usr/local/bin"

set_unless[:redis][:address]  = "127.0.0.1"
set_unless[:redis][:port]  = "6379"
set_unless[:redis][:pidfile] = "/var/run/redis.pid"
set_unless[:redis][:logfile] = "/var/log/redis.log"
set_unless[:redis][:loglevel] = 'notice'
set_unless[:redis][:dbdir] = "/var/lib/redis"
set_unless[:redis][:dbfile] = "dump.rdb"
set_unless[:redis][:client_timeout] = "300"
set_unless[:redis][:glueoutputbuf] = "yes"

set_unless[:redis][:conf_dir]  = "/etc/redis"
set_unless[:redis][:conf_file] = "#{node[:redis][:conf_dir]}/redis.conf"

set_unless[:redis][:saves] = [["900", "1"], ["300", "10"], ["60", "10000"]]

set_unless[:redis][:slave] = "no"
if redis[:slave] == "yes"
  set_unless[:master_server] = "redis-master." + domain
  set_unless[:master_port] = "6379"
end

