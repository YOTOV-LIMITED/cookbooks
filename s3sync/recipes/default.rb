#
# Cookbook Name:: s3sync
# Recipe:: default
#
# Copyright:: 2010, Critical Juncture
#
# Author:: Bob Burbach, Github: Peregrinator
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

remote_file "#{node[:s3sync][:install_path]}/#{node[:s3sync][:filename]}" do
  source "#{node[:s3sync][:url]}"
  not_if { ::File.exists?("#{node[:s3sync][:install_path]}/#{node[:s3sync][:filename]}") }
end

bash "Install s3Sync" do
  cwd "#{node[:s3sync][:install_path]}"
  code <<-EOH
  tar -xzvf #{node[:s3sync][:filename]}
  rm #{node[:s3sync][:filename]}
  EOH
  not_if do
    ::File.exists?("#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb")
  end
end

directory '/etc/s3conf' do
  owner "root"
  group "root"
  mode 0755
  recursive true
end

template "/etc/s3conf/s3config.yml" do
  source "s3config.yml.erb"
  mode 0644
  variables :aws_access_key_id     => node[:aws][:accesskey],
            :aws_secret_access_key => node[:aws][:secretkey],
            :ssl_cert_dir          => node[:s3sync][:ssl_cert_dir]
end

directory "#{node[:s3sync][:ssl_cert_dir]}" do
  owner "root"
  group "root"
  mode 0755
  recursive true
end

