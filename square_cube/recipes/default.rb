#
# Cookbook Name:: square_cube
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

if node[:chef][:roles].include?('square_cube')
  git node[:square_cube][:app_path] do
    user "deploy"
    group "deploy"
    repository node[:square_cube][:repo_url]
    reference "master"
    action :sync
  end

  bash "NPM install Square's cube" do
    user "root"
    cwd node[:square_cube][:app_path]
    code <<-EOH
      npm install
      EOH

    not_if do
      system("npm list | grep -q cube")
    end
  end


  #set up variables for collector service / upstart script
  service_name = "cube_collector"
  service_user = "deploy"
  service_user_home = (%x[cat /etc/passwd | grep #{service_user} | cut -d":" -f6]).chomp

  # Create a node service for this program with upstart
  template "/etc/init/#{service_name}.conf" do
    source "upstart.erb"
    variables :name   => service_name,
              :script => node[:square_cube][:collector][:path],
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

  file node[:square_cube][:collector][:path] do
    mode 0775
  end

  service service_name do
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
  end

  # generate collector config file
  template "#{node[:square_cube][:app_path]}/bin/collector-config.js" do
    source "collector-config.js.erb"
    owner service_user
    group service_user
    variables :mongo_host => node[:square_cube][:collector][:mongo_host],
              :mongo_port => node[:square_cube][:collector][:mongo_port],
              :mongo_database => node[:square_cube][:collector][:mongo_database],
              :mongo_username => node[:square_cube][:collector][:mongo_username],
              :mongo_password => node[:square_cube][:collector][:mongo_password],
              :http_port => node[:square_cube][:collector][:http_port],
              :udp_port => node[:square_cube][:collector][:udp_port]
    mode 0755

    notifies :restart, resources(:service => service_name)
  end


  #set up variables for evaluator service / upstart script
  service_name = "cube_evaluator"
  service_user = "deploy"
  service_user_home = (%x[cat /etc/passwd | grep #{service_user} | cut -d":" -f6]).chomp

  # Create a node service for this program with upstart
  template "/etc/init/#{service_name}.conf" do
    source "upstart.erb"
    variables :name   => service_name,
              :script => node[:square_cube][:evaluator][:path],
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

  file node[:square_cube][:evaluator][:path] do
    mode 0775
  end


  service service_name do
    provider Chef::Provider::Service::Upstart
    action [:enable, :start]
  end

  # generate collector config file
  template "#{node[:square_cube][:app_path]}/bin/evaluator-config.js" do
    source "evaluator-config.js.erb"
    owner service_user
    group service_user
    variables :mongo_host => node[:square_cube][:evaluator][:mongo_host],
              :mongo_port => node[:square_cube][:evaluator][:mongo_port],
              :mongo_database => node[:square_cube][:evaluator][:mongo_database],
              :mongo_username => node[:square_cube][:evaluator][:mongo_username],
              :mongo_password => node[:square_cube][:evaluator][:mongo_password],
              :http_port => node[:square_cube][:evaluator][:http_port]
    mode 0755

    notifies :restart, resources(:service => service_name)
  end

end
