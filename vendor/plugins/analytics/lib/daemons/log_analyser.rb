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

logger.info "[Log Analyser] Starting at #{Time.now}."
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
      begin
        Session.transaction do
          raise Trackster::InvalidSession unless session = Session.find_or_create_from(track)
          # extract_internal_search_terms!(track, session, web_analyser)
          raise Trackster::InvalidEvent unless event = session.events.create_from(track)
        end
      rescue Trackster::InvalidEvent
        logger.error "[Log Analyser] Event could not be created. URL: #{track.url}"
      rescue Trackster::InvalidSession
        logger.error "[Log Analyser] Sesssion was not found or created. Unknown web property? URL: '#{track.url}'"        
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

logger.info "[Log Analyser] Ending at #{Time.now}."