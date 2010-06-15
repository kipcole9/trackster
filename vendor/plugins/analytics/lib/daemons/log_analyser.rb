#!/usr/bin/env ruby
puts "STARTING UP LOG ANALYSER"
# Start rails environment; need to find environment.rb
rails_root = "#{File.dirname(__FILE__)}/../../../../.."
require "#{rails_root}/config/environment"
env_cap = Rails.env.capitalize

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
  puts "Log Analyser logging to #{logfile}"
  @logger ||= logfile ? TracksterLogger.new(logfile, 1) : Rails.logger
end

$RUNNING = true  
Signal.trap("TERM") do
  logger.info "[Log analyser daemon] #{env_cap}: termination requested at #{Time.now}."  
  $RUNNING = false
end

plugin_lib = "#{File.dirname(__FILE__)}/../"
require "#{plugin_lib}/analytics/log_analyser_daemon"
require "#{plugin_lib}/analytics/log_parser"
require "#{plugin_lib}/analytics/web_analytics"
require "#{plugin_lib}/analytics/system_info"

logger.info "[Log analyser daemon] #{env_cap}: starting at #{Time.now}."
log_analyser = LogAnalyserDaemon.new(:logger => logger)
log_analyser.log_analyser_loop
logger.info "[Log analyser daemon] #{env_cap}: ending at #{Time.now}."