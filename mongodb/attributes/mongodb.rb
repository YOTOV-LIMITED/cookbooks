default[:mongodb][:user]  = "mongodb"
default[:mongodb][:group] = "mongodb"

default[:mongodb][:bind_address] = "127.0.0.1"
default[:mongodb][:port]         = "27017"

default[:mongodb][:version]   = '2.0.0'
default[:mongodb][:file_name] = "mongodb-linux-#{kernel[:machine] || 'i686'}-#{mongodb[:version]}"
default[:mongodb][:url]       = "http://fastdl.mongodb.org/linux/#{mongodb[:file_name]}.tgz"

default[:mongodb][:root]       = "/usr/local/mongodb"
default[:mongodb][:bin_path]   = "/usr/local/bin/mongodb"
default[:mongodb][:data_dir]   = "/data/db"
default[:mongodb][:log_dir]    = "/var/log/mongodb"
default[:mongodb][:config_dir] = "/etc/mongodb"
default[:mongodb][:pid_dir]    = "/var/run"
default[:mongodb][:pid_path]   = "#{mongodb[:pid_dir]}/mongod.pid"

default[:mongodb][:username] = ''
default[:mongodb][:password] = ''
default[:mongodb][:database] = ''

default[:mongodb][:auth] = 'false'
