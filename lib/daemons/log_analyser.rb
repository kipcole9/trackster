#!/usr/bin/env ruby

# Specify environment and load rails
# Has knowledge of the deployment strategy to work out which
# environment to load.  We use a layout which is
# /u/apps/{appname}/{environment}/releases/..........
env = File.basename(File.expand_path("#{__FILE__}/../../../../.."))
if ["staging", "production"].include?(env)
  ENV["RAILS_ENV"] ||= env
else
  ENV["RAILS_ENV"] ||= "development"
end
require File.dirname(__FILE__) + "/../../config/environment"

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
  log_level = Trackster::Config.log_level || :info
  @logger ||= logfile ? TracksterLogger.new(logfile, log_level) : Rails.logger
end

$RUNNING = true  
Signal.trap("TERM") do
  @logger.info "[Log Analyser Daemon] (#{ENV["RAILS_ENV"]}) termination requested at #{Time.now}.\n"  
  $RUNNING = false
end

require "#{Rails.root}/lib/analytics/log_analyser_daemon"
log_analyser = LogAnalyserDaemon.new(:logger => logger)
logger.info "[Log Analyser Daemon] (#{ENV["RAILS_ENV"]}) starting at #{Time.now}.\n"
log_analyser.log_analyser_loop
logger.info "[Log Analyser Daemon] (#{ENV["RAILS_ENV"]}) ending at #{Time.now}.\n"