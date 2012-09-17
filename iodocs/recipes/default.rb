#
# Cookbook Name:: iodocs
# Recipe:: default
#
# Copyright 2012, Critical Juncture, LLC
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

git node[:iodocs][:app_path] do
  repository node[:iodocs][:repo_url]
  reference "master"
  action :checkout
end

template "#{node[:iodocs][:app_path]}/config.json" do
  source "config.json.erb"
  variables :title   => node[:iodocs][:title],
            :address => node[:iodocs][:address],
            :port    => node[:iodocs][:port],
            :debug   => node[:iodocs][:debug],
            :session_secret => node[:iodocs][:session_secret],
            :redis_host     => "redis.fr2.ec2.internal",
            :redis_port     => node[:redis][:port],
            :redis_password => "",
            :redis_database => node[:iodocs][:redis_database]
    
  mode "0644"
end
