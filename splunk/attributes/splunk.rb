default[:splunk][:package_name] = "splunk-4.2-96430-linux-2.6-amd64.deb"
default[:splunk][:package_url]  = "http://www.splunk.com/index.php/download_track?file=4.2/splunk/linux/splunk-4.2-96430-linux-2.6-amd64.deb&ac=&wget=true&name=wget&typed=releases"
default[:splunk][:install_path] = "/opt/splunk"
default[:splunk][:bin_path]     = "#{node[:splunk][:install_path]}/bin"


default[:splunk][:forwarder][:package_name] = "splunkforwarder-4.2-96430-linux-2.6-amd64.deb"
default[:splunk][:forwarder][:package_url]  = "http://www.splunk.com/index.php/download_track?file=4.2/universalforwarder/linux/splunkforwarder-4.2-96430-linux-2.6-amd64.deb&ac=&wget=true&name=wget&typed=releases"
default[:splunk][:forwarder][:install_path] = "/opt/splunkforwarder"
default[:splunk][:forwarder][:bin_path]     = "#{node[:splunk][:forwarder][:install_path]}/bin"

# expects [ {:path => '/var/log/apache2', :ignore_older_than => '7d'} ]
default[:splunk][:forwarder][:files_to_monitor] = []
default[:splunk][:files_to_monitor]             = []

default[:splunk][:reciever][:host]     = '127.0.0.1'
default[:splunk][:reciever][:port]     = 9997
default[:splunk][:reciever][:username] = ''
default[:splunk][:reciever][:password] = ''


#
# Forwarder Apps
#
default[:splunk][:forwarder][:apps][:app_directory]       = "#{node[:splunk][:forwarder][:install_path]}/etc/apps"

default[:splunk][:forwarder][:apps][:nix][:package_name]  = "splunk_nix_app.tar.gz"
default[:splunk][:forwarder][:apps][:nix][:app_directory] = "#{node[:splunk][:forwarder][:apps][:app_directory]}/unix"
