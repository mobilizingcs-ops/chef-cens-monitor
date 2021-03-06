#
# Cookbook Name:: monitor
# Recipe:: master
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

include_recipe "sensu::rabbitmq"
include_recipe "sensu::redis"
include_recipe "monitor::master-graphite"
include_recipe "monitor::_worker"
include_recipe "sensu::api_service"

# use uchiwa pw from chef-vault
chef_gem 'chef-vault'
require 'chef-vault'
uchiwa_admin = ChefVault::Item.load('sensu', 'uchiwa')
node.set['uchiwa']['settings']['user'] = 'localadmin'
node.set['uchiwa']['settings']['pass'] = uchiwa_admin['localadmin']

include_recipe "uchiwa"
include_recipe "monitor::default"