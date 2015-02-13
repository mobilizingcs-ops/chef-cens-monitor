#
# Cookbook Name:: monitor
# Recipe:: ohmage_checks
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
include_recipe "monitor::_check-ohmage"
include_recipe "monitor::_ohmage-metrics"

sensu_check "check-ohmage" do
  command "check-ohmage.rb"
  handlers ["default"]
  standalone true
  interval 120
end

sensu_check "ohmage-metrics" do
  type "metric"
  command "ohmage-metricss.rb -h localhost -d ohmage --ini '/etc/sensu/my.cnf'"
  handlers ["graphite"]
  standalone true
  interval 60
end