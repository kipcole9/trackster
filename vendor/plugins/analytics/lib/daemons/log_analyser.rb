#!/usr/bin/env ruby

# Signal that we're starting Rails for the Log analyser
# Which will mean the plugin init will do the requires
$LOG_ANALYSER = true

# How we signal the analyser to stop when a signal is received
$RUNNING = true  

# Flag for File::Tail library
# $DEBUG = true

# Start rails environment; need to find environment.rb
rails_root = "#{File.dirname(__FILE__)}/../../../../.."
require "#{rails_root}/config/environment"

# Include support methods for the analyser
include Daemons::AnalyserSupport

logger.info "[Log analyser] Starting at #{Time.now}."
tailer = LogTailer.new
parser = Analytics::LogParser.new

# This is where the real work begins. Tail the log, parse each entry into
# a hash and pass the hash to the analyser.  The analyser builds an object
# that is then passed for serializing to the database into Session and Event
tailer.tail do |log_line|
  parser.parse(log_line) do |log_attributes|
    next if log_attributes[:datetime] < last_logged_entry
    ActiveRecord::Base.verify_active_connections! 
    Analytics::TrackEvent.analyse(log_attributes) do |track|
      serialize_event(track)
    end
  end
end

logger.info "[Log analyser] Ending at #{Time.now}."