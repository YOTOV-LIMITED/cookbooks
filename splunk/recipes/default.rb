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

remote_file "/tmp/#{node[:splunk][:package_name]}" do
  source node[:splunk][:package_url]
  not_if { ::File.exists?("/tmp/#{node[:splunk][:package_name]}") }
end

execute "Install splunk from debian package, accept license and start on server boot" do
  command "dpkg -i /tmp/#{node[:splunk][:package_name]}; #{node[:splunk][:bin_path]}/splunk start --accept-license; #{node[:splunk][:bin_path]}/splunk enable boot-start"
  not_if {::File.exists?( node[:splunk][:bin_path] ) }
end

service "splunk" do
  service_name "splunk"
  start_command "#{node[:splunk][:bin_path]}/splunk start"
  stop_command "#{node[:splunk][:bin_path]}/splunk stop"
  restart_command "#{node[:splunk][:bin_path]}/splunk restart"
  
  supports [ :start, :stop, :restart ]
  action [:start]
end

#execute "Listen for data being forwarded" do
#  command "#{node[:splunk][:bin_path]}/splunk enable listen #{node[:splunk][:reciever][:port]} -auth '#{node[:splunk][:reciever][:username]}':'#{node[:splunk][:reciever][:password]}'"
#  returns [0,24] #24 indicates the port is already configured to be listened on
#end

template "#{node[:splunk][:install_path]}/etc/system/local/inputs.conf" do
  source "indexer/inputs.conf.erb"
  variables :files_to_monitor => node[:splunk][:files_to_monitor]
  notifies :restart, resources(:service => "splunk")
end

template "#{node[:splunk][:install_path]}/etc/system/local/props.conf" do
  source "indexer/props.conf.erb"
  notifies :restart, resources(:service => "splunk")
end
