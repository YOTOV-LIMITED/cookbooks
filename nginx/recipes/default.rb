#
# Cookbook Name:: nginx
# Recipe:: default
# Author:: AJ Christensen <aj@junglist.gen.nz>
#
# Copyright 2008-2009, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'nginx::vhost'

package "nginx"

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

if node[:chef][:roles].include?('splunk_proxy')
  directory "#{node[:nginx][:log_dir]}/splunk.#{node[:nginx][:host_name]}" do
    mode 0755
    owner node[:nginx][:user]
    action :create
    recursive true
  end
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end


template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => 'nginx')
end

# add location for varnish errors if it happens to go down
# or can't reach the app servers
if node[:chef][:roles].include?('proxy') && !node[:chef][:roles].include?('vagrant')
  directory "/var/www/apps/fr2/current/public/nginx" do
    action :create
    recursive true
  end
  
  execute "Get file for 502 & 503 errors from s3" do
    cwd "/var/www/apps/fr2/current/public"
    command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get config.internal.federalregister.gov:502_503_proxy.html 502_503_proxy.html"
  end
  
  execute "Get image header_bg.png for 502 & 503 errors from s3" do
    cwd "/var/www/apps/fr2/current/public/nginx"
    command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get config.internal.federalregister.gov:images/header_bg.png header_bg.png"
  end
  
  execute "Get image seal.png for 502 & 503 errors from s3" do
    cwd "/var/www/apps/fr2/current/public/nginx"
    command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get config.internal.federalregister.gov:images/seal.png seal.png"
  end
  
  execute "Get image logotype.png for 502 & 503 errors from s3" do
    cwd "/var/www/apps/fr2/current/public/nginx"
    command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get config.internal.federalregister.gov:images/logotype.png logotype.png"
  end
end

# add resque logs
if node[:chef][:roles].include?('resque_proxy')
  directory "/var/log/nginx/resque.#{node[:app][:url]}" do
    action :create
    recursive true
  end
end

# disable default vhost
nginx_site "default" do
  enable false
end
