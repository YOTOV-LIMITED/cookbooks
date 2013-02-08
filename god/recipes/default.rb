#
# Cookbook Name:: god
# Recipe:: default
#
# Copyright 2009, Opscode, Inc.
# Modified 2013, Critical Juncture, LLC
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

gem_package "god" do
  action :install
end

template "/etc/init.d/god" do
  source "god.initd.conf.erb"
  mode 0744
  action :create
end

directory "/etc/god/conf.d" do
  recursive true
  owner "root"
  group "root"
  mode 0755
end

service "god" do
  supports :status => true, :restart => true
  action :nothing
end


template "/etc/god/god.conf" do
  source "master.god.erb"
  owner "root"
  group "root"
  mode 0755
  variables(
    :domain => node[:god][:domain],
    :email_name => node[:god][:email_name],
    :email_domain => node[:god][:email_domain]
  )
  notifies :restart, resources(:service => "god")
end

node[:god][:monitor].each do |monitor|
  template "/etc/god/conf.d/#{monitor['options']['queue']}.god" do
    source "#{monitor['name']}.god.erb"
    owner "root"
    group "root"
    mode 0644
    variables( 
      :options => monitor['options']
    )
    notifies :restart, resources(:service => "god")
  end
end
