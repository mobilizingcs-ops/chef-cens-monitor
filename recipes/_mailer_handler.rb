#
# Cookbook Name:: monitor
# Recipe:: _mailer_handler
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

sensu_gem "mail"

cookbook_file "/etc/sensu/handlers/mailer.rb" do
  source "handlers/mailer.rb"
  mode 0755
end

sensu_snippet "mailer" do
  content(
  	:admin_gui => "http://alerts.ohmage.org:3000/",
    :mail_from => "sensu@ohmage.org",
    :mail_to => "technolengy@gmail.com",
    :smtp_address => "localhost",
    :smtp_port => "25"
  )
end

sensu_handler "mailer" do
  type "pipe"
  command "mailer.rb"
end
