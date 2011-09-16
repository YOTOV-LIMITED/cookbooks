#
# Cookbook Name:: mongodb
# Recipe:: default

group node[:mongodb][:group] do
  action [ :create, :manage ]
end

user node[:mongodb][:user] do
  comment "MongoDB Server"
  gid node[:mongodb][:group]
  home node[:mongodb][:root]
  action [ :create, :manage ]
end

[node[:mongodb][:log_dir], node[:mongodb][:data_dir], node[:mongodb][:pid_dir]].each do |dir|
  directory dir do
    owner node[:mongodb][:user]
    group node[:mongodb][:group]
    mode 0755
    recursive true
    action :create
    not_if { File.directory?(dir) }
  end
end

remote_file "/tmp/#{node[:mongodb][:file_name]}.tgz" do
  source node[:mongodb][:url]
  not_if do
    ::File.exists?("/tmp/#{node[:mongodb][:file_name]}.tgz") || 
    ( ::File.exists?('/usr/local/bin/mongod') &&
      system("/usr/local/bin/mongod --version | grep -q '#{node[:mongodb][:version]}'")
    )
  end
end

bash "install-mongodb" do
  cwd "/tmp"
  code <<-EOH
    tar zxvf #{node[:mongodb][:file_name]}.tgz
    rm -Rf #{node[:mongodb][:root]}/
    mv -f #{node[:mongodb][:file_name]}/ #{node[:mongodb][:root]}
  EOH
  not_if { ::File.exists?('/usr/local/bin/mongod') &&
           system("/usr/local/bin/mongod --version | grep -q '#{node[:mongodb][:version]}'") 
         }
end


%w(bsondump mongod mongoexport mongoimport mongos mongostat mongo mongodump mongofiles mongorestore mongosniff).each do |binary|
  link "/usr/local/bin/#{binary}" do
    to "/usr/local/mongodb/bin/#{binary}"
  end
end

# create config directory and file
directory "/etc/mongodb" do
  action :create
  owner "root"
  group "root"
  mode 0755
end

directory node[:mongodb][:data_dir] do
  action :create
  owner "root"
  group "root"
  mode 0755
end
if node[:ec2] && node[:chef][:roles].include?('database')
  unless FileTest.directory?(node[:mongodb][:ec2_path])
    directory node[:mongodb][:ec2_path] do
      action :create
      owner node[:mongodb][:user]
      group node[:mongodb][:group]
    end

    execute "install-mysql" do
      command "mv #{node[:mongodb][:data_dir]} #{node[:mongodb][:ec2_path]}"
      not_if do FileTest.directory?(node[:mongodb][:ec2_path]) end
    end
  end

  %w(/var/lib/mongodb).each do |path|
    directory path do
      owner node[:mongodb][:user]
      group node[:mongodb][:group]
      mode "0755"
      action :create
      not_if do FileTest.directory?(path) end
    end
  end

  mount node[:mongodb][:data_dir] do
    device node[:mongodb][:ec2_path]
    fstype "none"
    options "bind"
    action [:enable, :mount]
    # Do not execute if its already mounted (ubunutu/linux only)
    not_if "cat /proc/mounts | grep #{node[:mongodb][:data_dir]}"
  end
end

  
template_path = (8.04..9.04).include?(node.platform_version.to_f) ? "/etc/event.d/mongodb" : "/etc/init/mongodb.conf"
template template_path do
  source "mongodb.upstart.erb"
  variables :mongodb_path     => node[:mongodb][:bin_path],
            :config           => "#{node[:mongodb][:config_dir]}/mongodb.conf",
            :user             => node[:mongodb][:user],
            :mongodb_pid_path => node[:mongodb][:pid_path]
  mode "0644"
end

service "mongodb" do
  provider Chef::Provider::Service::Upstart
  action [ :enable ]
end


template "/etc/mongodb/mongodb.conf" do
  source "mongodb.conf.erb"
  owner "root"
  group "root"
  mode 0744
  notifies :restart, resources(:service => "mongodb")
end
