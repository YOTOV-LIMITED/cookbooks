
# Cookbook Name:: princexml
# Recipe:: default
#
# Copyright 2013, Critical Juncture, LLC
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

# basic fonts (microsoft true type - Arial, Times, etc.)
# package 'msttcorefonts' #requires license confirmation which hasn't been scripted

# prince dependencies
%w(libc6 libtiff4 libgif4 libcurl3 libfontconfig1 libjpeg8 libssl0.9.8).each do |pkg|
  package pkg
end

#remote_file node[:princexml][:deb_path] do
  #source node[:princexml][:download_url]
  #mode "0755"

  #not_if do
    #File.exists?(node[:princexml][:deb_path])
  #end
#end

#script "install prince from downloaded deb package" do
  #interpreter "bash"
  #user "root"
  #code <<-EOH
    #dpkg -i #{node[:princexml][:deb_path]}
    #EOH
  #not_if do
    #system("prince --version | grep -q '#{node[:princexml][:version]}'")
  #end
#end


#############################

puts "#####!!!!!!! #{node[:princexml][:download_url]} !!!!!!!!#####"

remote_file node[:princexml][:tar_path] do
  source node[:princexml][:download_url]
  mode "0755"

  not_if do
    File.exists?(node[:princexml][:tar_path])
  end
end

script "install prince from downloaded tar package" do
  interpreter "bash"
  user "root"
  code <<-EOH
    cd "/tmp"
    tar xzvf #{node[:princexml][:tar_package]}
    cd prince-8.1r4-linux-amd64
    ./install.sh
    EOH
  not_if do
    system("prince --version | grep -q '#{node[:princexml][:version]}'")
  end
end

directory '/usr/share/fonts/truetype/open-sans' do
  owner 'root'
  group 'root'
  mode 0755
  recursive true
  action :create
  not_if do File.directory?("/usr/share/fonts/truetype/open-sans") end
end

%w(OpenSans-Bold OpenSans-BoldItalic OpenSans-ExtraBold OpenSans-ExtraBoldItalic OpenSans-SemiboldItalic OpenSans-Italic OpenSans-Light OpenSans-LightItalic OpenSans-Regular OpenSans-Semibold).each do |font|
  cookbook_file "/usr/share/fonts/truetype/open-sans/#{font}.ttf" do
    source "Open_Sans/#{font}.ttf"
    mode 0644
    owner 'root'
    group 'root'

    not_if do
      File.exists?("/usr/share/fonts/truetype/open-sans/#{font}.ttf")
    end
  end
end

execute "update font cache" do
  user "root"
  command "fc-cache -f -v"
end
