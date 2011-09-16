default_unless[:sphinx][:version]="0.9.9"
default_unless[:sphinx][:url]="http://www.sphinxsearch.com/downloads/sphinx-#{sphinx[:version]}.tar.gz"
default[:sphinx][:path]="/opt/#{sphinx[:version]}"
default_unless[:sphinx][:src_path]="/opt/src"
default[:sphinx][:tar_file]="#{sphinx[:src_path]}/#{sphinx[:version]}.tar.gz"
default[:sphinx][:libstemmer]=false
default[:sphinx][:configure_options]="" #"--with-libstemmer"
default[:sphinx][:tar_file_checksum]=""
default[:sphinx][:bin_path] = '/usr/local/bin/searchd'

default[:sphinx][:server_address] = 'localhost'
default[:sphinx][:server_port]    = 3312
default[:sphinx][:memory_limit]   = '528M'
