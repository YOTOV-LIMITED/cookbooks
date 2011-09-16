#
# Cookbook Name:: sphinx
# Recipe:: default
#
# Copyright 2009, Example Com
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

package node[:platform_version].to_f >= 9.10 ? 'libmysqlclient16-dev' : 'libmysqlclient15-dev'

if node[:platform_version].to_f >= 11.04
  # g++ doesn't seem to be installed?
  package 'g++'
end

directory node[:sphinx][:src_path] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if do File.exists?(node[:sphinx][:path]) end
end

remote_file node[:sphinx][:tar_file] do
  source node[:sphinx][:url]
  mode "0755"
  #checksum node[:sphinx][:tar_file_checksum]
  not_if do 
    system("#{node[:sphinx][:bin_path]} --help | grep -q '#{node[:sphinx][:version]}'")
  end
end

if node[:sphinx][:libstemmer]
  remote_file "#{node[:sphinx][:src_path]}/libstemmer_c.tgz" do
    source "http://snowball.tartarus.org/dist/libstemmer_c.tgz"
    mode "0755"
    checksum "b642b8921915128bd95c99d302d33701cba8b5afbda81b762c118cbadfb7670f"
  end

  script "install_sphinx" do
    interpreter "bash"
    user "root"
    cwd node[:sphinx][:src_path]
    not_if do
      system("#{node[:sphinx][:bin_path]} --help | grep -q '#{node[:sphinx][:version]}'")
    end
    code <<-EOH
      tar -xvf #{node[:sphinx][:tar_file]}
      cd  sphinx-#{node[:sphinx][:version]}
      tar -xvf ../libstemmer_c.tgz
      ./configure #{node[:sphinx][:configure_options]}
      make
      make install
      EOH
  end
else
  script "install_sphinx" do
    interpreter "bash"
    user "root"
    cwd node[:sphinx][:src_path]
    not_if do
      system("#{node[:sphinx][:bin_path]} --help | grep -q '#{node[:sphinx][:version]}'")
    end
    code <<-EOH
      tar -xvf #{node[:sphinx][:tar_file]}
      cd  sphinx-#{node[:sphinx][:version]}
      ./configure #{node[:sphinx][:configure_options]}
      make
      make install
      EOH
  end
end

if node.attribute?("sphinx") && node.attribute?("rails") && node[:rails][:using_thinking_sphinx] == 'true'
  
  template_path = (8.04..9.04).include?(node.platform_version.to_f) ? "/etc/event.d/searchd" : "/etc/init/searchd.conf"

  template template_path do
    source "searchd.upstart.erb"
    variables :searchd_path => node[:sphinx][:bin_path],
              :config       => "#{node[:app][:app_root]}/#{node[:rails][:using_shared] == 'true' ? 'shared/' : 'current/'}config/#{node[:rails][:environment]}.sphinx.conf",
              :user         => node[:capistrano][:deploy_user]
    mode "0644"
  end
  
  service "searchd" do
    provider Chef::Provider::Service::Upstart
    action [ :enable, :start ]
  end
end

