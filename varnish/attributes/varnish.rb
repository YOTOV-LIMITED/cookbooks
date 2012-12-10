case platform
when "debian","ubuntu"
  default[:varnish][:dir]     = "/etc/varnish"
  default[:varnish][:default] = "/etc/default/varnish"
end

default[:varnish][:version] = '2.1.5'
default[:varnish][:url]     = "http://repo.varnish-cache.org/source/varnish-#{node[:varnish][:version]}.tar.gz"


# default options
default[:varnish][:vcl_conf]       = '/etc/varnish/default.vcl'
# Binding to 0.0.0.0 typically indicates that the process is listening 
# on all configured IPv4 addresses on all interfaces
# On ec2 the machine is connected via an elastic_ip and doesn't know it's ipaddress
default[:varnish][:listen_address] = '0.0.0.0'
default[:varnish][:listen_port]    = '6081'

# admin options
default[:varnish][:admin_listen_address] = '0.0.0.0'
default[:varnish][:admin_listen_port]    = '6082'

# where to proxy requests to 
default[:varnish][:app_proxy_host] = '127.0.0.1'
default[:varnish][:app_proxy_port] = '8080'
default[:varnish][:app_proxy_host_probe_url] = '/status'
default[:varnish][:my_fr2_proxy_host_probe_url] = '/my/status'
default[:varnish][:static_proxy_host] = '127.0.0.1'
default[:varnish][:static_proxy_port] = '8080'

# THREAD SETTINGS
#bottom limit for the number of threads to maintain, per pool, regardless of traffic
default[:varnish][:min_threads]           = 800 
#the maximum, collectively for all pools
default[:varnish][:max_threads]           = 4000 
#probably want one pool per core
default[:varnish][:thread_pools]          = 1
#delay between the launching of each thread
default[:varnish][:thread_pool_add_delay] = 1
default[:varnish][:thread_timeout]        = 120

# if setting malloc you will only need to set the storage size - storage file is not used with malloc
default[:varnish][:storage_type] = 'malloc'
default[:varnish][:storage_file] = '/tmp'
default[:varnish][:storage_size] = '1G'
default[:varnish][:varnish_ttl]  = 120

# Maximum number of open files (for ulimit -n)
default[:varnish][:nfiles] = 131072


# **** THIS PARAM BORKS OUR VARNISH IF WE SET IT ****
# To avoid locking, Varnish allocates a chump of memory to each thread, session and object. 
# While keeping the object workspace small is a good thing to reduce the memory footprint 
# sometimes the session workspace is a bit too small, specially when ESI is in use. 
# The default sess_workspace is 16kB
#default[:varnish][:session_workspace_size] = 64*1024 #64k 