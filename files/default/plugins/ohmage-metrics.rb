#! /usr/bin/env ruby
#
#   ohmage-metrics.rb
#
# DESCRIPTION:
#
# OUTPUT:
#   graphite metrics 
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: mysql and stuff
#
# LICENSE:
#   Steve Nolen technolengy@gmail.com
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require 'mysql2'
require 'socket'
require 'inifile'

class Mysql2Graphite < Sensu::Plugin::Metric::CLI::Graphite
  option :host,
         short: '-h HOST',
         long: '--host HOST',
         description: 'Mysql Host to connect to',
         required: true

  option :port,
         short: '-P PORT',
         long: '--port PORT',
         description: 'Mysql Port to connect to',
         proc: proc(&:to_i),
         default: 3306

  option :database,
         short: '-d DB_NAME',
         long: '--database DB_NAME',
         description: 'MySQL ohmage db name',
         default: "ohmage"
 
 
  option :username,
         short: '-u USERNAME',
         long: '--user USERNAME',
         description: 'Mysql Username'

  option :password,
         short: '-p PASSWORD',
         long: '--pass PASSWORD',
         description: 'Mysql password',
         default: ''

  option :ini,
         short: '-i',
         long: '--ini VALUE',
         description: 'My.cnf ini file'

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.ohmage"

  option :socket,
         short: '-S SOCKET',
         long: '--socket SOCKET'

  option :verbose,
         short: '-v',
         long: '--verbose',
         boolean: true

  def run
    # props to https://github.com/coredump/hoardd/blob/master/scripts-available/mysql.coffee

    metrics = {
      'client' => [
        'ohmage-android',
        'NULL',
        'mobilize-android',
        'dashboard',
        'android',
        'mobilize-navbar',
        'curl',
        'ohmage-gwt',
        'gwt',
        'R-Ohmage',
        'ohmage-mwf',
        'ohmageEasyPost',
        'plotapp',
        'mobilize-mwf',
        'browser-mwf',
        'mobilize',
        'mobilize-mwf-ios',
        'account_policy',
        'doc_app'
      ],
      'uri' => [
        '/app/config/read',
        '/app/user/create',
        '/app/user/update',
        '/app/user/change_password',
        '/app/user/read',
        '/app/user_info/read',
        '/app/user/delete',
        '/app/user/auth',
        '/app/user/auth_token',
        '/app/user/register',
        '/app/user/activate',
        '/app/user/reset_password',
        '/app/user/logout',
        '/app/user/whoami',
        '/app/user/setup',
        '/app/user_stats/read',
        '/app/class/read',
        '/app/class/create',
        '/app/class/delete',
        '/app/class/update',
        '/app/campaign/read',
        '/app/campaign/delete',
        '/app/campaign/update',
        '/app/campaign/create',
        '/app/campaign/search',
        '/app/document/create',
        '/app/document/read',
        '/app/documen/read/contents',
        '/app/document/update',
        '/app/document/delete',
        '/app/image/read',
        '/app/image/batch/zip/read',
        '/app/registration/read',
        '/app/survey/upload',
        '/app/survey_response/read',
        '/app/survey_response/update',
        '/app/survey_response/delete',
        '/app/survey_response/function/read',
        '/app/mobility/upload',
        '/app/mobility/read',
        '/app/mobility/read/csv',
        '/app/mobility/read/chunked',
        '/app/mobility/aggregate/read',
        '/app/mobility/dates/read',
        '/app/observer/create',
        '/app/observer/update',
        '/app/stream/upload',
        '/app/stream/read',
        '/app/audit/read'
      ]
      'general' => {
        'Bytes_received' =>         'rxBytes',
      }
    }

    config[:host].split(' ').each do |mysql_host|
      mysql_shorthostname = mysql_host.split('.')[0]
      if config[:ini]
        ini = IniFile.load(config[:ini])
        section = ini['client']
        db_user = section['user']
        db_pass = section['password']
      else
        db_user = config[:username]
        db_pass = config[:password]
      end
      begin
        mysql = Mysql2::Client.new(
          host: mysql_host,
          port: config[:port],
    database: config[:database],
          username: db_user,
          password: db_pass,
          socket: config[:socket]
        )

      results = mysql.query('select * from audit where respond_millis > (UNIX_TIMESTAMP(date_sub(NOW(), INTERVAL 1 MINUTE)))*1000;')
      rescue => e
        puts e.message
      end

      output "#{config[:scheme]}.audit.count.total", results.count

      #enumerate the response success/failure
      count_success = 0
      count_failure = 0
      cumul_resp_time = 0
      max_resp_time = 0
      min_resp_time = 1000000000 #some really really high number
      results.each do |row|
        case row['response'].to_s
         when /success/
          count_success += 1
         when /failure/
          count_failure += 1
  end
      resp_millis = row['respond_millis'].to_i - row['received_millis'].to_i
      if resp_millis > max_resp_time
        max_resp_time = resp_millis
      end
      if resp_millis < min_resp_time
        min_resp_time = resp_millis
      end
      cumul_resp_time += resp_millis 
      end
      output "#{config[:scheme]}.audit.count.success", count_success
      output "#{config[:scheme]}.audit.count.failure", count_failure
      if results.count > 0
       output "#{config[:scheme]}.audit.response_time.average", cumul_resp_time / results.count
       output "#{config[:scheme]}.audit.response_time.min", min_resp_time
       output "#{config[:scheme]}.audit.response_time.max", max_resp_time
      end
      

      begin      
        client_results = mysql.query('select client,count(*) as count from audit where respond_millis > (UNIX_TIMESTAMP(date_sub(NOW(), INTERVAL 1 MINUTE)))*1000 group by client;')
      rescue => e
        puts e.message
      end
      client_results.each do |row|
        metrics['client'].each do |client_string|
          if client_string.eql?(row['client'])
            output "#{config[:scheme]}.audit.client.#{client_string}", row['count']
          end
        end
      end
      begin
        uri_results = mysql.query('select uri,count(*) as count from audit where respond_millis > (UNIX_TIMESTAMP(date_sub(NOW(), INTERVAL 1 MINUTE)))*1000 group by uri')
      rescue => e
        puts e.message
      end
      uri_results.each do |row|
        metrics['uri'].each do |uri_string|
          if uri_string.eql?(row['uri'])
            uri_string = uri_string.sub('/app/', '').sub("/", '_')
            output "#{config[:scheme]}.audit.uri.#{uri_string}"
          end
        end
      end
    end

    ok
  end
end
