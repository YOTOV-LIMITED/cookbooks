#
# Author:: Bob Burbach (<info@criticaljuncture.org>)
# Cookbook Name:: nodejs
# Recipe:: default
# Description:: "Installs and configures Node.js"
# Version:: "0.1"
# Copyright 2010, Critical Juncture
# Providers and upstart template courtesy of Tikibooth Limited, https://github.com/digitalbutter/cookbook-node
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

directory node[:nodejs][:source_path] do
  mode 0755
  action :create
  recursive true
end

remote_file "/usr/local/src/node-#{node[:nodejs][:version]}-linux-x64.tar.gz" do
  source "#{node[:nodejs][:source_url]}"
  not_if { ::File.exists?("/usr/local/src/node-#{node[:nodejs][:version]}-linux-x64.tar.gz") }
end

bash "Install NodeJS #{node[:nodejs][:version]} from precompiled binaries" do
  cwd node[:nodejs][:source_path]
  code <<-EOH
  tar -zxvf node-#{node[:nodejs][:version]}-linux-x64.tar.gz
  chown -R root:root /usr/local/src/node-#{node[:nodejs][:version]}-linux-x64
  cd node-#{node[:nodejs][:version]}-linux-x64
  cp bin/node /usr/local/bin/
  cp bin/node-waf /usr/local/bin/
  cp bin/npm /usr/local/bin/
  EOH

  not_if do
    ::File.exists?("/usr/local/bin/node") &&
    system("/usr/local/bin/node -v | grep -q '#{node[:nodejs][:version]}'")
  end
end

if node[:nodejs][:install_npm] == "yes"
  bash "Install Node Package Manager" do
    cwd node[:nodejs][:source_path]
    user "root"
    code <<-EOH
      curl -o /tmp/install.sh https://npmjs.org/install.sh 
      clean=no sh /tmp/install.sh
      EOH
  end
  
  node[:nodejs][:npm][:packages].each do |npm_package|
    bash "Install NPM package #{npm_package[:name]}" do
      code <<-EOH
        npm install #{npm_package[:name]} #{npm_package[:global] == true ? '-g' : ''}
        EOH

      not_if do
        system("npm list #{npm_package[:global] == true ? '-g' : ''} | grep -q #{npm_package[:name]}")
      end
    end
  end
end


