#!/usr/bin/env ruby
puts "Collector service is starting at #{Time.now}"
#
# This is the entry point for processing nginx log files
# as part of the Traphos analytics system. This should be 
# installed as a system service (which it is in our Chef 
# recipes)
#
# Start rails environment; need to find environment.rb
rails_root = "#{File.dirname(__FILE__)}/../../../../.."
require "#{rails_root}/config/environment"
env_cap = Rails.env.capitalize

# Our gems
require "file/tail"
require "inifile"
require "graticule"

# Flag for File::Tail library
# $DEBUG = true

class TracksterLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n" 
  end 
end

def logger
  return @logger if defined?(@logger)
  logfile = "#{Trackster::Config.analytics_logfile_directory}/log_analyser.log" if Trackster::Config.analytics_logfile_directory  
  @logger ||= Rails.logger # => maybe do this later. logfile ? TracksterLogger.new(logfile, 1) : Rails.logger
end

$RUNNING = true  
Signal.trap("TERM") do
  logger.info "[Log analyser daemon] #{env_cap}: termination requested (TERM signal received); terminating."  
  $RUNNING = false
end

Signal.trap("CONT") do
  # The runit environment sends CONT signals as part of the restart and termination
  # process but apart from trapping it here it has no value to us.
  # logger.info "[Log analyser daemon] #{env_cap}: restart requested (CONT signal received)."  
end

Signal.trap("HUP") do
  logger.info "[Log analyser daemon] #{env_cap}: reconfigure requested (HUP signal) but that's not yet available."  
end

plugin_lib = "#{File.dirname(__FILE__)}/../"
require "#{plugin_lib}/log_tailer"
require "#{plugin_lib}/analytics/track_event"
require "#{plugin_lib}/analytics/log_parser"
require "#{plugin_lib}/analytics/referrer"
require "#{plugin_lib}/analytics/system"
require "#{plugin_lib}/analytics/url"
require "#{plugin_lib}/analytics/params"
require "#{plugin_lib}/analytics/visitor"
require "#{plugin_lib}/analytics/session"
require "#{plugin_lib}/analytics/location"
require "#{plugin_lib}/analytics/email_client"

tailer = LogTailer.new
parser = Analytics::LogParser.new

logger.info "[Log analyser daemon] #{env_cap}: starting at #{Time.now}."

# TODO - get these out of here - and finish implementation properly
def extract_internal_search_terms!(row, session, web_analyser)
  return unless session.property && (search_param = session.property.search_parameter)
  internal_search = internal_search_terms(search_param, row[:url], web_analyser)
  row[:internal_search_terms] = internal_search if internal_search
end

def internal_search_terms(search_param, url, web_analyser)
  web_analyser.parse_url_parameters(url)[search_param]
end

# This is where the real work begins. Tail the log, parse each entry into
# a hash and pass the hash to the analyser.  The analyser builds an object
# that can then be further processed.
@last_logged_entry = Event.last.tracked_at
tailer.tail do |log_line|
  parser.parse(log_line) do |log_attributes|
    next if log_attributes[:datetime] < @last_logged_entry
    ActiveRecord::Base.verify_active_connections! 
    Analytics::TrackEvent.analyse(log_attributes) do |track|
      begin
        Session.transaction do
          if session = Session.find_or_create_from_track(track)
            session.save! if session.new_record?
            # extract_internal_search_terms!(track, session, web_analyser)
            if event = Event.create_from_track(session, track)
              event.save! 
              session.update_viewcount!
            else
              logger.error "[Log Analyser] Event could not be created. URL: #{track.url}"
            end
          else
            logger.error "[Log Analyser] Sesssion was not found or created. Unknown web property? URL: #{track.url}"
          end
        end
      rescue Mysql::Error => e
        logger.warn "[Log Analyser] Database could not save this data: #{e.message}"
        logger.warn track.inspect
      rescue ActiveRecord::RecordInvalid => e
        logger.error "[Log Analyser] Invalid record detected: #{e.message}"
        logger.error track.inspect
      end
    end
  end
end

logger.info "[Log analyser daemon] #{env_cap}: ending at #{Time.now}."