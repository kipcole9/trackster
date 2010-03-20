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
  @logger ||= logfile ? TracksterLogger.new(logfile, 1) : Rails.logger
end

$RUNNING = true  
Signal.trap("TERM") do
  logger.info "[Log analyser daemon] #{ENV['RAILS_ENV'].capitalize}: termination requested at #{Time.now}."  
  $RUNNING = false
end

require "#{Rails.root}/lib/analytics/log_analyser_daemon"
logger.info "[Log analyser daemon] #{ENV['RAILS_ENV'].capitalize}: starting at #{Time.now}."
log_analyser = LogAnalyserDaemon.new(:logger => logger)
log_analyser.log_analyser_loop
logger.info "[Log analyser daemon] #{ENV['RAILS_ENV'].capitalize}: ending at #{Time.now}."