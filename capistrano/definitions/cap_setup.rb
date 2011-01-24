#
# Cookbook Name:: capistrano
# Definition:: cap_setup
#
# Copyright 2009, Opscode, Inc.
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

define :cap_setup, :path => nil, :owner => "root", :group => "root", :appowner => "nobody" do
  include_recipe "capistrano"

  directory params[:path] do
    owner params[:owner]
    group params[:group]
    mode 0755
    action :create
    recursive true
    not_if do FileTest.directory?(params[:path]) end
  end
  
  # after chef-174 fixed, change mode to 2775
  %w{ shared }.each do |dir|
    directory "#{params[:path]}/#{dir}" do
      owner params[:owner]
      group params[:group]
      mode 0775
      action :create
      not_if do File.directory?("#{params[:path]}/#{dir}") end
    end
  end
  
  if node[:ec2] && node[:chef][:roles].include?('staging')
    mount "#{node[:app][:web_dir]}/apps/#{node[:app][:name]}/shared" do
      device "/vol/apps/#{node[:apache][:name]}/shared"
      fstype "none"
      options "bind"
      action [:enable, :mount]
      # Do not execute if its already mounted (ubunutu/linux only)
      not_if "cat /proc/mounts | grep #{node[:app][:web_dir]}/apps/#{node[:app][:name]}"
    end

    # we really only want to do this if it's not already owned...
    # directory "#{params[:path]}/shared" do
    #   owner params[:owner]
    #   group params[:group]
    #   mode 0775
    # end
  end
  
  # create directories in shared
  %w{ log config/initializers system data tmp db/sphinx/production }.each do |dir|
    directory "#{params[:path]}/shared/#{dir}" do
      owner params[:appowner]
      group params[:group]
      mode "775"
      recursive true
      action :create
      not_if do File.directory?("#{params[:path]}/shared/#{dir}") end
    end
  end 
  
  file "#{params[:path]}/shared/log/production.log" do
    owner params[:appowner]
    group params[:group]
    mode 0666
    action :create
    not_if do File.exists?("#{params[:path]}/shared/log/production.log") end
  end
end
