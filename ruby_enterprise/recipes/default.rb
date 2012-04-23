#
# Cookbook Name:: ruby_enterprise
# Recipe:: default
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Sean Cribbs (<seancribbs@gmail.com>)
# Author:: Michael Hale (<mikehale@gmail.com>)
# 
# Copyright:: 2009-2010, Opscode, Inc.
# Copyright:: 2009, Sean Cribbs
# Copyright:: 2009, Michael Hale
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

include_recipe "build-essential"

%w{ libssl-dev libreadline6-dev }.each do |pkg|
  package pkg
end

remote_file "/tmp/ruby-enterprise-#{node[:ruby_enterprise][:version]}.tar.gz" do
  source "#{node[:ruby_enterprise][:url]}.tar.gz"
  not_if { ::File.exists?("/tmp/ruby-enterprise-#{node[:ruby_enterprise][:version]}.tar.gz") }
end

bash "Install Ruby Enterprise Edition" do
  cwd "/tmp"
  code <<-EOH
  tar zxf ruby-enterprise-#{node[:ruby_enterprise][:version]}.tar.gz
  ruby-enterprise-#{node[:ruby_enterprise][:version]}/installer \
    --auto=#{node[:ruby_enterprise][:install_path]} \
    --dont-install-useful-gems
  EOH
  not_if do
    ::File.exists?("#{node[:ruby_enterprise][:install_path]}/bin/ree-version") &&
    system("#{node[:ruby_enterprise][:install_path]}/bin/ree-version | grep -q '#{node[:ruby_enterprise][:version]}$'")
  end
end

binaries = %w(erb gem gem1.8 irb passenger-config passenger-install-apache2-module passenger-install-nginx-module passenger-make-enterprisey passenger-memory-stats passenger-spawn-server passenger-status passenger-stress-test rackup rake rdoc ree-version ri ruby testrb)
binaries.each do |binary|
  link "/usr/bin/#{binary}" do
    to "#{node[:ruby_enterprise][:install_path]}/bin/#{binary}"
  end
end

# the package chef uses for ruby causes trouble after the fact, so... bye bye
# if we uninstall the package it will get re-added on next run.
directory "/usr/lib/ruby" do
  recursive true
  action :delete
end

link "/usr/bin/ruby" do
  to "#{node[:ruby_enterprise][:install_path]}/bin/ruby"
end
link "/usr/bin/ruby1.8" do
  to "#{node[:ruby_enterprise][:install_path]}/bin/ruby"
end

execute "set global path" do
  command 'echo \'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/ruby-enterprise/bin"\' | tee /etc/environment'
end

execute "echo gem path" do
  command 'echo `gem environment` | tee /tmp/foo'
end

gem_package "chef" do
  version node[:bootstrap][:chef][:client_version]
  not_if "gem list chef | grep chef" # gem list doesn't return 1 on error so we use grep too
end
