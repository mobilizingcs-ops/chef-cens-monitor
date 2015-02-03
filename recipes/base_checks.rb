#
# Cookbook Name:: monitor
# Recipe:: base_checks
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
include_recipe "monitor::_check-disk"

sensu_check "check-disk" do
  command "check-disk.rb -x nfs -w 85 -c 95"
  handlers ["default", "mailer"]
  standalone true
  interval 60
  additional(:occurrences => 2, :refresh => 1800 )
end

sensu_check "crond_check" do
  command "check-procs.rb -p cron -C 1"
  handlers ["default", "mailer"]
  standalone true
  interval 30
end