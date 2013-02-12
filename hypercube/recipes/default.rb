#
# Cookbook Name:: hypercube
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
if node[:chef][:roles].include?('hypercube')
  include_recipe "square_cube"

  git node[:hypercube][:app_path] do
    user node[:hypercube][:user]
    group node[:hypercube][:group]
    repository node[:hypercube][:repo_url]
    reference "master"
    action :sync
  end

  template "#{node[:hypercube][:app_path]}/config/servers.json" do
    source "servers.json.erb"
    user node[:hypercube][:user]
    group node[:hypercube][:group]
    variables :servers => node[:hypercube][:servers]
    mode 0644
  end

  execute "generate hypercube dashboard" do
    cwd node[:hypercube][:app_path]
    user node[:hypercube][:user]
    group node[:hypercube][:group]

    command "ruby create_dashboard.rb"
  end

  directory "/var/log/nginx/#{node[:hypercube][:domain]}" do
    action :create
    recursive true
  end

  include_recipe "nginx"

  template "/etc/nginx/sites-available/hypercube" do
    source "nginx_hypercube.conf.erb"
    variables :domain => node[:hypercube][:domain],
              :host   => node[:hypercube][:host],
              :port   => node[:hypercube][:port],
              :cube_host => node[:square_cube][:evaluator][:host],
              :cube_port => node[:square_cube][:evaluator][:http_port]

    notifies :restart, resources(:service => "nginx")
  end

  nginx_site "hypercube" do
    enable true
  end

end

if node[:chef][:roles].include?('proxy')
  directory "/var/log/nginx/#{node[:hypercube][:domain]}" do
    action :create
    recursive true
  end

  include_recipe "nginx"

  execute "create nginx htpasswd entry for hypercube" do
    user "root"
    group "root"
    command <<-EOH
      htpasswd -cb /etc/nginx/htpasswd_hypercube #{node[:hypercube][:username]} #{node[:hypercube][:password]}
    EOH

    notifies :restart, resources(:service => "nginx")
  end


  template "/etc/nginx/sites-available/hypercube" do
    source "nginx_proxy.conf.erb"
    variables :domain => node[:hypercube][:domain],
              :host   => node[:hypercube][:host],
              :port   => node[:hypercube][:port]

    notifies :restart, resources(:service => "nginx")
  end

  nginx_site "hypercube" do
    enable true
  end
end

