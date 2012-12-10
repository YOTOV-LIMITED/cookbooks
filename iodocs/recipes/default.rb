#
# Cookbook Name:: iodocs
# Recipe:: default
#
# Copyright 2012, Critical Juncture, LLC
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

include_recipe "nodejs"

git node[:iodocs][:app_path] do
  user "deploy"
  group "deploy"
  repository node[:iodocs][:repo_url]
  reference "master"
  action :sync
end

bash "NPM install iodocs" do
  user "root"
  cwd node[:iodocs][:app_path]
  code <<-EOH
    npm install
    EOH

  not_if do
    system("npm list | grep -q iodocs")
  end
end

#set up variables for service / upstart script
service_name = "iodocs"
service_user = "deploy"
service_user_home = (%x[cat /etc/passwd | grep #{service_user} | cut -d":" -f6]).chomp

# Create a node service for this program with upstart
template "/etc/init/#{service_name}.conf" do
  source "iodocs.upstart.erb"
  variables :name   => "iodocs",
            :script => "#{node[:iodocs][:app_path]}/app.js",
            :user   => service_user,
            :user_home => service_user_home,
            :args => ""
end

file "/var/log/#{service_name}.log" do
  owner service_user
  group "root"
  mode 0644
  action :create
end

service service_name do
  provider Chef::Provider::Service::Upstart
  action [:enable, :start]
end


template "#{node[:iodocs][:app_path]}/config.json" do
  source "config.json.erb"
  variables :title   => node[:iodocs][:title],
            :address => node[:iodocs][:address],
            :port    => node[:iodocs][:port],
            :debug   => node[:iodocs][:debug],
            :session_secret => node[:iodocs][:session_secret],
            :redis_host     => "redis.fr2.ec2.internal",
            :redis_port     => node[:redis][:port],
            :redis_password => "",
            :redis_database => node[:iodocs][:redis_database]
    
  mode "0644"

  notifies :restart, resources(:service => service_name)
end
