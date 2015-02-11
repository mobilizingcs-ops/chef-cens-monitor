require "rubygems"
require "json"
require "net/http"
require "uri"

uri = URI.parse("http://localhost:8080/app/config/read")
http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)

begin
 response = http.request(request)

 if response.code == "200"
  result = JSON.parse(response.body)
  version = result["data"]["application_version"]
  commit = result["data"]["application_build"]
  puts "OK - ohmage server is running, version: #{version}, commit: #{commit}"
  exit 0
 else
  puts "WARNING - ohmage server returned a non-200 response"
  exit 1
 end
rescue Net::ReadTimeout
 puts "CRITICAL - ohmage server request has timed out"
 exit 2
rescue Errno::ECONNREFUSED
 puts "CRITICAL - ohmage server is down"
 exit 2
end