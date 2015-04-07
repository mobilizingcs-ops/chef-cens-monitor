#!/usr/bin/env ruby
#
# Check RT4
# ===
#
# checks ps aux output for rt-server.fcgi process
#

procs = `ps aux`
running = false
procs.each_line do |proc|
  running = true if proc.include?('rt-server.fcgi')
end
if running
  puts 'OK - RT4 daemon is running'
  exit 0
else
  puts 'WARNING - RT4 daemon is NOT running'
  exit 1
end