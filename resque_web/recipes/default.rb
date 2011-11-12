#
# Cookbook Name:: resque_web
# Recipe:: default
#
# Copyright 2011 Bob Burbach, Critical Juncture, LLC.
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

gem_package "resque" do
  version "1.19.0"
end

git node[:resque_web][:app_path] do
  repository "git://github.com/kennethkalmer/resque-web-passenger.git"
  reference "master"
  action :checkout
end

# script "bundle install" do
#   interpreter "bash"
#   user node[:capistrano][:deploy_user]
#   cwd node[:resque_web][:app_path]
#   code <<-EOH
#     bundle install
#   EOH
# end


template "#{node[:resque_web][:app_path]}/resque-web.yml" do
  source "resque-web.yml"
  variables :password    => node[:resque_web][:password],
            :config_path => "#{node[:app][:app_root]}/current/config/resque.yml",
            :environment => node[:rails][:environment]
  mode "0644"
end



