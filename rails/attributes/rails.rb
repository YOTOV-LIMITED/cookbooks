default[:rails][:version]       = false
default[:rails][:environment]   = "production"
default[:rails][:max_pool_size] = 4

# log rotation via logrotate
default[:rails][:logrotate][:interval] = 'daily'
default[:rails][:logrotate][:keep_for] = 7

default[:rails][:using_shared] = 'true'
default[:rails][:using_mongoid] = 'false'
