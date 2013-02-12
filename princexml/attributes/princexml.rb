
default[:princexml][:version]      = '8.1 rev 4'
default[:princexml][:package_name] = "prince_#{princexml[:version].gsub(" rev ", "-")}_ubuntu12.04_amd64.deb"
default[:princexml][:tar_package]  = "prince-#{princexml[:version].gsub(" rev ", "r")}-linux-amd64.tar.gz"
default[:princexml][:deb_path]     = "/tmp/#{princexml[:package_name]}"
default[:princexml][:tar_path]     = "/tmp/#{princexml[:tar_package]}"

default[:princexml][:download_url] = "http://www.princexml.com/download/#{princexml[:tar_package]}"


