#
# Cookbook Name:: collectd
# Recipe:: default
#
# Copyright 2012, Critical Juncture, LLC
# portions based off github.com/coderanger/chef-collectd
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

package "collectd"

service "collectd" do
  supports :restart => true, :status => true
end

directory "/etc/collectd" do
  owner "root"
  group "root"
  mode "755"
end

directory "/etc/collectd/plugins" do
  owner "root"
  group "root"
  mode "755"
end

directory node[:collectd][:base_dir] do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

directory node[:collectd][:plugin_dir] do
  owner "root"
  group "root"
  mode "755"
  recursive true
end

template "/etc/collectd/collectd.conf" do
  source "collectd.conf.erb"
  owner "root"
  group "root"
  mode "644"
  notifies :restart, resources(:service => "collectd")
end

if node[:collectd][:use_cube]
  template "/etc/collectd/plugins/write_http.conf" do
    source "plugins/write_http.conf.erb"
    owner "root"
    group "root"
    mode "644"
    notifies :restart, resources(:service => "collectd")
  end
end

node[:collectd][:plugins].each do |plugin|
  collectd_plugin plugin[:name] do
    options plugin[:options]
  end
end
