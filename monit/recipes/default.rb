#
# Cookbook Name:: monit
# Recipe:: default
#
# Copyright 2013, Critical Juncture, LLC
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

package "monit"

service "monit" do
  supports :reload => true, :restart => true, :status => true
  action [:enable, :start]
end

template "/etc/monit/monitrc" do
  source "monitrc.erb"
  user 'root'
  group 'root'
  mode 0600
  notifies :restart, resources(:service => "monit") 
end

node[:monit][:monitors].each do |monitor|
  template "/etc/monit/conf.d/#{monitor[:name]}.monit" do
    source "#{monitor[:monitor_type]}.monit.erb"
    user 'root'
    group 'root'
    mode 0644
    variables :user => node[:capistrano][:deploy_user],
              :group => node[:capistrano][:deploy_user],
              :rails_env => node[:rails][:environment],
              :options => monitor[:options]
    notifies :restart, resources(:service => "monit") 
  end
end

