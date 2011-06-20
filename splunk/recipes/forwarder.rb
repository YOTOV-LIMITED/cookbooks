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

remote_file "/tmp/#{node[:splunk][:forwarder][:package_name]}" do
  source node[:splunk][:forwarder][:package_url]
  not_if { ::File.exists?("/tmp/#{node[:splunk][:forwarder][:package_name]}") }
end

execute "Install splunk universal forwarder from debian package, accept license, start on server boot, and change password" do
  command "dpkg -i /tmp/#{node[:splunk][:forwarder][:package_name]}; #{node[:splunk][:forwarder][:bin_path]}/splunk start --accept-license; #{node[:splunk][:forwarder][:bin_path]}/splunk enable boot-start; #{node[:splunk][:forwarder][:bin_path]}/splunk edit user admin -password #{node[:splunk][:reciever][:password]}"
  not_if {::File.exists?( node[:splunk][:forwarder][:bin_path] ) }
end

service "splunk" do
  service_name "splunk"
  start_command "#{node[:splunk][:forwarder][:bin_path]}/splunk start"
  stop_command "#{node[:splunk][:forwarder][:bin_path]}/splunk stop"
  restart_command "#{node[:splunk][:forwarder][:bin_path]}/splunk restart"
  
  supports [ :start, :stop, :restart ]
end

execute "Add server to forward to" do
  command "#{node[:splunk][:forwarder][:bin_path]}/splunk add forward-server #{node[:splunk][:reciever][:host]}:#{node[:splunk][:reciever][:port]} -auth '#{node[:splunk][:reciever][:username]}':'#{node[:splunk][:reciever][:password]}'"
  notifies :restart, resources(:service => "splunk")
  returns [0,22] #22 indicates the forward-server is already configured
end

template "#{node[:splunk][:forwarder][:install_path]}/etc/system/local/inputs.conf" do
  source "forwarder/inputs.conf.erb"
  variables :files_to_monitor => node[:splunk][:forwarder][:files_to_monitor]
  notifies :restart, resources(:service => "splunk")
end
