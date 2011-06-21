# Cookbook Name:: varnish
# Recipe:: default
# Author:: Bob Burbach <Github: Peregrinator>
#
# Copyright 2010, Critical Juncture
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

# These urls were helpful in configuring Varnish properly
# http://www.engineyard.com/blog/2010/varnish-its-not-just-for-wood-anymore/
# http://www.all2e.com/Ressourcen/Artikel-und-Fallstudien/Varnish-installation-and-setup-on-ez-publish-based-systems
# http://kristian.blog.linpro.no/2010/01/26/varnish-best-practices/
# http://www.mail-archive.com/varnish-misc@varnish-cache.org/msg00336.html

group "varnish" do
  gid 1003
  not_if "cat /etc/group | grep varnish"
end

user "varnish" do
  comment "Varnish User"
  uid "4000"
  gid "varnish"
  not_if "cat /etc/password | grep varnish"
end

directory "#{node[:varnish][:dir]}" do
  owner 'varnish'
  group 'varnish'
  action :create
  not_if { ::File.directory?("#{node[:varnish][:dir]}") }
end

remote_file "/usr/local/src/varnish-#{node[:varnish][:version]}.tar.gz" do
  source "#{node[:varnish][:url]}"
  not_if { ::File.exists?("/usr/local/src/varnish-#{node[:varnish][:version]}.tar.gz") }
end

bash "Install Varnish" do
  user 'root'
  cwd "/usr/local/src"
  code <<-EOH
    tar -zxvf varnish-#{node[:varnish][:version]}.tar.gz
    chown -R root:root /usr/local/src/varnish-#{node[:varnish][:version]}
    cd varnish-#{node[:varnish][:version]}
    ./configure --prefix=/usr/local --sysconfdir=/etc --localstatedir=/var/lib/ --mandir=/usr/share/man
    make
    make install
    ldconfig
  EOH
  not_if { ::File.directory?("/usr/local/varnish-#{node[:varnish][:version]}") }
end

template "/etc/init.d/varnish" do
  source "varnish.init.d.erb"
  owner "varnish"
  group "varnish"
  mode 0755
end

template "#{node[:varnish][:default]}" do
  source "varnish.sysconfig.erb"
  owner "varnish"
  group "varnish"
  mode 0644
end

directory "/var/lib/varnish/" do
  owner "varnish"
  group "varnish"
  mode "0755"
end

service "varnish" do
  supports :restart => true, :reload => true
  action [ :enable ]
end

template "#{node[:varnish][:dir]}/default.vcl" do
  source "default.vcl.erb"
  owner "varnish"
  group "varnish"
  mode 0644
  notifies :restart, resources(:service => "varnish")
end

