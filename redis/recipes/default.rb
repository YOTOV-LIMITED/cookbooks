#
# Author:: Benjamin Black (<b@b3k.us>)
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2009, Benjamin Black
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

remote_file "/tmp/redis-#{node[:redis][:version]}.tar.gz" do
  source "#{node[:redis][:source_url]}.tar.gz"
  not_if { ::File.exists?("/tmp/redis-#{node[:redis][:version]}.tar.gz") }
end

directory node[:redis][:bin_path] do
  mode 0755
  action :create
  recursive true
end

bash "Install Redis #{node[:redis][:version]} from source" do
  cwd "/tmp"
  code <<-EOH
  tar xvzf redis-#{node[:redis][:version]}.tar.gz
  cd redis-#{node[:redis][:version]}
  make
  cp -f redis-server "#{node[:redis][:bin_path]}/" && cp redis-cli "#{node[:redis][:bin_path]}/"
  EOH

  not_if do
    ::File.exists?("#{node[:redis][:bin_path]}") &&
    system("#{node[:redis][:bin_path]} -v | grep -q '#{node[:redis][:version]}$'")
  end
end

template "/etc/init/redis.conf" do
  source "redis.upstart.erb"
end

service "redis" do
  provider Chef::Provider::Service::Upstart
  supports :restart => true
  action :enable
end

directory @node[:redis][:dbdir] do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

directory @node[:redis][:conf_dir] do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

template @node[:redis][:conf_file] do
  source "redis.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "redis")
end
