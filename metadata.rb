name             "monitor"
maintainer       "Steve Nolen"
maintainer_email "technolengy@gmail.com"
license          "Apache 2.0"
description      "A cookbook for monitoring services, using Sensu, a monitoring framework. Fork from chef-monitor"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.18"

%w[
  ubuntu
  debian
  centos
  redhat
  fedora
].each do |os|
  supports os
end

depends "sensu"
depends "sudo"
depends "uchiwa"
