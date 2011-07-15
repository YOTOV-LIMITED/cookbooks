#
# Cookbook Name:: mysql
# Recipe:: client
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

p = package "mysql-devel" do
  ubuntu_package = node[:platform_version].to_f >= 9.10 ? 'libmysqlclient16-dev' : 'libmysqlclient15-dev'

  package_name value_for_platform(
    [ "centos", "redhat", "suse" ] => { "default" => "mysql-devel" },
    "default" => ubuntu_package
  )
  action :nothing
end

p.run_action(:install)

package "mysql-client" do
  package_name value_for_platform(
    [ "centos", "redhat", "suse" ] => { "default" => "mysql" },
    "default" => "mysql-client"
  )
  action :install
end

if node[:chef][:roles].include?('staging') || node[:chef][:roles].include?('app')
  case node[:platform]
  when "centos","redhat", "suse"
    package "ruby-mysql" do
      action :install
    end

  else
    r = gem_package "mysql" do
      version "2.7"
      action :nothing
    end

    r.run_action(:install)
  end
end
