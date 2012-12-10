#
# Cookbook Name:: rails
# Recipe:: default
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

#include_recipe "ruby"

include_recipe "rails::logrotate"

%w{ rails actionmailer actionpack activerecord activesupport activeresource }.each do |rails_gem|
  node[:rails][:versions].each do |rails_version|
    gem_package rails_gem do  
      version rails_version
      action :install
    end
  end
end


directory "#{node[:app][:web_dir]}/apps/#{node[:app][:name]}/current/public/articles" do
  owner "#{node[:capistrano][:deploy_user]}"
  group "#{node[:capistrano][:deploy_user]}"
  mode 0755
  action :create
  recursive true
end

if node[:chef][:roles].include?('app') || node[:chef][:roles].include?('worker')
  template "#{node[:app][:web_dir]}/apps/#{node[:app][:name]}/shared/config/database.yml" do
    variables :environment   => node[:rails][:environment],
              :adapter       => "mysql",
              :host          => node[:mysql][:database_server_fqdn], 
              :port          => node[:mysql][:server_port],
              :database_name => node[:mysql][:database_name],
              :password      => node[:mysql][:server_root_password]
    source "database/app_server.mysql.yml.erb"
    owner node[:capistrano][:deploy_user]
    group node[:capistrano][:deploy_user]
    mode 0644
  end

  # MY FR #
  [ node[:app][:my_fr][:root] ].each do |my_fr_dir|
    directory my_fr_dir do
      owner node[:capistrano][:deploy_user]
      group node[:capistrano][:deploy_user]
      mode 0755
      action :create
      recursive true
    end
  end

  branch_ref = node[:rails][:environment] == 'production' ? 'production' : 'master'
  git "#{node[:app][:my_fr][:root]}" do
    user node[:capistrano][:deploy_user]
    group node[:capistrano][:deploy_user]
    repository node[:app][:my_fr][:repo_url]
    reference branch_ref
    action :sync
  end

  template "#{node[:app][:my_fr][:root]}/config/database.yml" do
    variables :environment   => node[:rails][:environment],
              :adapter       => "mysql2",
              :host          => node[:mysql][:database_server_fqdn], 
              :port          => node[:mysql][:server_port],
              :database_name => node[:mysql][:my_fr_database_name],
              :password      => node[:mysql][:server_root_password]
    source "database/app_server.mysql.yml.erb"
    mode 0644
  end
end

if node[:rails][:using_mongoid] == 'true' && ( node[:chef][:roles].include?('app') || node[:chef][:roles].include?('worker') )
  directory "#{node[:app][:app_root]}/#{node[:rails][:using_shared] == 'true' ? 'current/' : ''}config" do
    owner "#{node[:capistrano][:deploy_user]}"
    group "#{node[:capistrano][:deploy_user]}"
    mode 0755
    action :create
    recursive true
  end

  template "#{node[:app][:app_root]}/#{node[:rails][:using_shared] == 'true' ? 'current/' : ''}config/mongoid.yml" do
    variables :environment   => node[:rails][:environment],
              :host          => node[:mongodb][:bind_address], 
              :port          => node[:mongodb][:port],
              :database_name => node[:mongodb][:database],
              :password      => node[:mongodb][:password],
              :username      => node[:mongodb][:username]
    source "database/mongoid.yml.erb"
    mode 0644
  end
end


# template "#{node[:app][:web_dir]}/apps/#{node[:app][:name]}/shared/config/sphinx.yml" do
#   variables :server_address => node[:sphinx][:server_address],
#             :server_port    => node[:sphinx][:server_port],
#             :memory_limit   => node[:sphinx][:memory_limit],
#             :version        => node[:sphinx][:version]
#   source "sphinx.yml.erb"
#   mode 0644
# end

unless node[:chef][:roles].include?('vagrant')
  # FR2 #
  execute "Get private config file amazon.yml" do
    cwd "#{node[:app][:web_dir]}/apps/#{node[:app][:name]}/shared/config"
    command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get #{node[:ubuntu][:aws_config_path]}:amazon.yml amazon.yml"
    user "#{node[:capistrano][:deploy_user]}"
    group "#{node[:capistrano][:deploy_user]}"
  end
  execute "Get private config file api_keys.yml" do
    cwd "#{node[:app][:web_dir]}/apps/#{node[:app][:name]}/shared/config"
    command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get #{node[:ubuntu][:aws_config_path]}:api_keys.yml api_keys.yml"
    user "#{node[:capistrano][:deploy_user]}"
    group "#{node[:capistrano][:deploy_user]}"
  end
  execute "Get private config file cloudkicker_config.rb" do
    cwd "#{node[:app][:web_dir]}/apps/#{node[:app][:name]}/shared/config"
    command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get #{node[:ubuntu][:aws_config_path]}:cloudkicker_config.rb cloudkicker_config.rb"
    user "#{node[:capistrano][:deploy_user]}"
    group "#{node[:capistrano][:deploy_user]}"
  end

  # FR2, MY FR #
  [ "#{node[:app][:app_root]}/shared", node[:app][:my_fr][:root] ].each do |app_root|
    execute "Get private config file sendgrid.yml" do
      cwd "#{app_root}/config"
      command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get #{node[:ubuntu][:aws_config_path]}:sendgrid.yml sendgrid.yml"
      user "#{node[:capistrano][:deploy_user]}"
      group "#{node[:capistrano][:deploy_user]}"
    end
  end

  # FR2 #
  execute "Get FR2 private config file secrets.yml" do
    cwd "#{node[:app][:app_root]}/shared/config"
    command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get #{node[:ubuntu][:aws_config_path]}:secrets.yml secrets.yml"
    user "#{node[:capistrano][:deploy_user]}"
    group "#{node[:capistrano][:deploy_user]}"
  end
  # MY FR #
  execute "Get MY FR private config file secrets.yml" do
    cwd "#{node[:app][:my_fr][:root]}/config"
    command "#{node[:s3sync][:install_path]}/s3sync/s3cmd.rb get #{node[:ubuntu][:aws_config_path]}:my_fr2_secrets.yml secrets.yml"
    user "#{node[:capistrano][:deploy_user]}"
    group "#{node[:capistrano][:deploy_user]}"
  end

end

gem_package "bundler" do
  version "1.0.0"
end

link "/usr/bin/bundle" do
  to "#{node[:ruby_enterprise][:install_path]}/bin/bundle"
end

#execute "bundle install" do
  #command "bundle install --deployment --gemfile #{node[:app][:web_dir]}/apps/#{node[:app][:name]}/shared/tmp/Gemfile --without development test"
  #user "#{node[:capistrano][:deploy_user]}"
  #group "#{node[:capistrano][:deploy_user]}"
  #action :nothing
#end

#unless node[:chef][:roles].include?('vagrant')
  #%w(Gemfile Gemfile.lock).each do |f|
    #template "#{node[:app][:web_dir]}/apps/#{node[:app][:name]}/shared/tmp/#{f}" do
      #source "#{f}"
      #notifies :run, resources(:execute => "bundle install")
    #end
  
    #file "#{node[:app][:web_dir]}/apps/#{node[:app][:name]}/shared/tmp/#{f}" do
      #owner "#{node[:capistrano][:deploy_user]}"
      #group "#{node[:capistrano][:deploy_user]}"
    #end
  #end
#end
