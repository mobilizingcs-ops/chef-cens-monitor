#
# Cookbook Name:: monitor
# Recipe:: _check-raid
#
# Copyright 2015, Steve Nolen
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

#add the hwraid repo and install megacli
include_recipe "apt"
apt_repository "hwraid" do
  uri "http://hwraid.le-vert.net/#{node['platform']}"
  key "http://hwraid.le-vert.net/debian/hwraid.le-vert.net.gpg.key"
  distribution node['lsb']['codename']
  components ["main"]
end 
package "megacli"
node.set["monitor"]["sudo_commands"] = ["/usr/sbin/megacli -AdpAllInfo -aALL"]
include_recipe "monitor::_sudo"


cookbook_file "/etc/sensu/plugins/check-raid.rb" do
  source "plugins/check-raid.rb"
  mode 0755
end