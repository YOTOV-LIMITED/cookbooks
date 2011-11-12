#
# Cookbook Name:: ec2
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
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
directory "/vol" do
  owner "ubuntu"
  group "ubuntu"
  mode "0755"
  action :create
  not_if "test -d /vol"
end

if node[:chef][:roles].include?('database') && node[:aws][:ebs][:database]
  mount_point = node[:aws][:ebs][:database][:mount_point]
  device_loc  = node[:aws][:ebs][:database][:device]
elsif node[:chef][:roles].include?('worker') && node[:aws][:ebs][:worker]
  mount_point = node[:aws][:ebs][:worker][:mount_point]
  device_loc  = node[:aws][:ebs][:worker][:device]
end

if mount_point && device_loc
  mount mount_point do
    device device_loc
    fstype "xfs"
    options "rw noatime"
    action [:enable, :mount]
    # Do not execute if its already mounted (ubunutu/linux only)
    not_if "cat /proc/mounts | grep /vol"
  end
end

package 'ec2-api-tools' do
  action :install
end
