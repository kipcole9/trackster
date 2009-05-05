#!/usr/bin/env ruby

# Specify environment and load rails
# Has knowledge of the deployment strategy to work out which
# environment to load.  We use a layout which is
# /u/apps/{appname}/{environment}/..........
env = File.basename(File.expand_path("#{__FILE__}/../../../.."))
if ["staging", "production"].include?(env)
  ENV["RAILS_ENV"] ||= env
else
  ENV["RAILS_ENV"] ||= "development"
end
require File.dirname(__FILE__) + "/../../config/environment"

# Flag for File::Tail library
# $DEBUG = true

$RUNNING = true  
Signal.trap("TERM") do
  ActiveRecord::Base.logger.info "Trackster log analyser (#{ENV["RAILS_ENV"]}) termination requested at #{Time.now}.\n"  
  $RUNNING = false
end

log_analyser = LogAnalyserDaemon.new
ActiveRecord::Base.logger.info "Trackster log analyser (#{ENV["RAILS_ENV"]}) starting at #{Time.now}.\n"
log_analyser.log_analyser_loop
ActiveRecord::Base.logger.info "Trackster log analyser (#{ENV["RAILS_ENV"]}) ending at #{Time.now}.\n"