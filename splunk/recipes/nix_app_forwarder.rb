#
# Cookbook Name:: splunk
# Recipe:: default
#
# Copyright 2011, Critical Juncture, LLC
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

include_recipe "splunk::forwarder"

cookbook_file "/tmp/#{node[:splunk][:forwarder][:apps][:nix][:package_name]}" do
  source "apps/nix/unix.tar.gz"
  not_if { ::File.exists?("/tmp/#{node[:splunk][:forwarder][:apps][:nix][:package_name]}") }
end

bash "Install Unix App" do
  cwd node[:splunk][:forwarder][:apps][:app_directory]
  code <<-EOH
    tar xvzf /tmp/#{node[:splunk][:forwarder][:apps][:nix][:package_name]}
  EOH
end

template "#{node[:splunk][:forwarder][:apps][:nix][:app_directory]}/local/app.conf" do
  source "apps/forwarder/nix/app.conf.erb"
  variables :enabled    => "enabled",
            :configured => true,
            :visible    => true
  notifies :restart, resources(:service => "splunk")
end

template "#{node[:splunk][:forwarder][:apps][:nix][:app_directory]}/local/app.conf" do
  source "apps/forwarder/nix/app.conf.erb"
  # 1=disabled, 0=enabled
  variables :vmstat     => 0,
            :iostat     => 0,
            :ps         => 0,
            :top        => 0,
            :netstat    => 1,
            :protocol   => 1,
            :open_ports => 1,
            :time       => 1,
            :lsof       => 1,
            :df         => 0,
            :who        => 1,
            :last_log   => 1,
            :interfaces => 1,
            :cpu        => 0,
            :rlog       => 0,
            :package    => 0,
            :hardware   => 1,
            :var_log    => 1,
            :etc        => 1,
            :etc_file_change => 1,
            :users_with_login_priv => 1
  notifies :restart, resources(:service => "splunk")
end

