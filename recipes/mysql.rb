#
# Cookbook Name:: monitor
# Recipe:: mysql
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

include_recipe "monitor::default"
include_recipe "monitor::_check-mysql-alive"
include_recipe "monitor::_mysql-metrics"

#this assumes you already have acct info in /etc/sensu/my.cnf. stop assuming that.

sensu_check "check-mysql-alive" do
  command "check-mysql-alive.rb -h localhost -d ohmage --ini '/etc/sensu/my.cnf'"
  handlers ["default"]
  standalone true
  interval 60
end

sensu_check "mysql-metrics" do
  type "metric"
  command "mysql-metrics.rb -h localhost --ini '/etc/sensu/my.cnf'"
  handlers ["metrics"]
  standalone true
  interval 60
end