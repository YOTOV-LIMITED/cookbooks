#
# Cookbook Name:: wkhtmltopdf
# Recipe:: default
#
# Copyright 2011, Critical Juncture
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

include_recipe "git"

script "install qt build depdencies" do
  interpreter "bash"
  user "root"
  cwd "/"
  code <<-EOH
          apt-get -q -y build-dep libqt4-gui libqt4-network libqt4-webkit
          EOH
end


package 'xorg'

# for stiching pdfs together
package 'pdftk'


git node[:wkhtmltopdf_qt][:path] do
  repository "git://gitorious.org/+wkhtml2pdf/qt/wkhtmltopdf-qt.git"
  reference "staging"
  action :sync
end

# script "install wkhtmltopdf-qt" do
#   interpreter "bash"
#   user "root"
#   cwd node[:wkhtmltopdf_qt][:path]
#   #not_if do File.exists?(node[:wkhtmltopdf_qt][:path]) end
#   code <<-EOH
#         ./configure -nomake tools,examples,demos,docs,translations -opensource -prefix ../wkqt
#         make -j3
#         make install
#         EOH
# end

git node[:wkhtmltopdf][:path] do
  repository "git://github.com/antialize/wkhtmltopdf.git"
  reference "master"
  action :checkout
end


# script "install wkhtmltopdf" do
#   interpreter "bash"
#   user "root"
#   cwd node[:wkhtmltopdf][:path]
#   #not_if do File.exists?(node[:wkhtmltopdf][:path]) end
#   code <<-EOH
#           ../wkqt/bin/qmake
#           make -j3
#           make install
#           EOH
# end
