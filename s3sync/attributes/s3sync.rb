#
# Cookbook Name:: s3sync
# Attributes:: s3sync
#
# Copyright:: 2010, Critical Juncture
#
# Author:: Bob Burbach, Github: Peregrinator
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
default[:s3sync][:filename]     = 's3sync.tar.gz'
default[:s3sync][:url]          = "http://s3.amazonaws.com/ServEdge_pub/s3sync/#{s3sync[:filename]}"
default[:s3sync][:install_path] = '/usr/local'
default[:s3sync][:ssl_cert_dir] = '/etc/ssl/certs'
