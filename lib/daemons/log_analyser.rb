#!/usr/bin/env ruby

# Specify environment and load rails
ENV["RAILS_ENV"] ||= "development" # Change: look at directory path and decide (based on our deployment strategy)
require File.dirname(__FILE__) + "/../../config/environment"

# Flag for File::Tail library
$DEBUG = true

$RUNNING = true  
Signal.trap("TERM") do
  ActiveRecord::Base.logger.info "Trackster log analyser termination requested at #{Time.now}.\n"  
  $RUNNING = false
end

log_analyser = LogAnalyserDaemon.new
ActiveRecord::Base.logger.info "Trackster log analyser starting at #{Time.now}.\n"
log_analyser.log_analyser_loop
ActiveRecord::Base.logger.info "Trackster log analyser ending at #{Time.now}.\n"