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

default node[:iodocs][:app_path] = "/var/www/apps/iodocs"
default node[:iodocs][:repo_url] = "git://github.com/mashery/iodocs.git"
default node[:iodocs][:address]  = "0.0.0.0"
default node[:iodocs][:port]     = 3000
default node[:iodocs][:title]    = "I/O Docs - http://github.com/mashery/iodocs"
default node[:iodocs][:debug]    = false
default node[:iodocs][:session_secret] = "12345"
default node[:iodocs][:redis_database] = 0
