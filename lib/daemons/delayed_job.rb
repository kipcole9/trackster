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

class TracksterLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n" 
  end 
end

def logger
  return @logger if defined?(@logger)
  logfile = "#{Trackster::Config.analytics_logfile_directory}/delayed_job.log" if Trackster::Config.analytics_logfile_directory  
  @logger ||= logfile ? TracksterLogger.new(logfile, 1) : Rails.logger
end

# Start the delayed job worker
Delayed::Worker.new.start
