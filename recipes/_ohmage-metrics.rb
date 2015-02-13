#
# Cookbook Name:: monitor
# Recipe:: _mysql-metrics
#
# Copyright 2013, Sean Porter Consulting
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

#assumes /etc/sensu/my.cnf exists. stop doing this.

include_recipe "monitor::default"

#install this dumb mysqlclient-dev package.
package "libmysqlclient-dev" do
	action :install
end

sensu_gem "mysql2"
sensu_gem "mysql"
sensu_gem "inifile"

cookbook_file "/etc/sensu/plugins/ohmage-metrics.rb" do
  source "plugins/ohmage-metrics.rb"
  mode 0755
end