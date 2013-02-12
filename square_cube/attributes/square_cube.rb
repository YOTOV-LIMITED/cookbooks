#
# Cookbook Name:: square_cube
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

default[:square_cube][:repo_url] = "git://github.com/square/cube.git"
default[:square_cube][:app_path] = "/var/www/apps/cube"

default[:square_cube][:collector][:path] = "#{node[:square_cube][:app_path]}/bin/collector.js"
default[:square_cube][:evaluator][:path] = "#{node[:square_cube][:app_path]}/bin/evaluator.js"

default[:square_cube][:collector][:mongo_host]     = "127.0.0.1"
default[:square_cube][:collector][:mongo_port]     = 27017
default[:square_cube][:collector][:mongo_database] = "cube_development"
default[:square_cube][:collector][:mongo_username] = ""
default[:square_cube][:collector][:mongo_password] = ""
default[:square_cube][:collector][:http_port]      = 1080
default[:square_cube][:collector][:udp_port]       = 1180

default[:square_cube][:evaluator][:mongo_host]     = "127.0.0.1"
default[:square_cube][:evaluator][:mongo_port]     = 27017
default[:square_cube][:evaluator][:mongo_database] = "cube_development"
default[:square_cube][:evaluator][:mongo_username] = ""
default[:square_cube][:evaluator][:mongo_password] = ""
default[:square_cube][:evaluator][:http_port]      = 1081

