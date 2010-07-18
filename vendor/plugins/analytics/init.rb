config.gem "file-tail",     :lib => false
config.gem "inifile",       :lib => false
config.gem "graticule",     :lib => false
config.gem "json",          :lib => false
config.gem 'htmlentities',  :lib => false

# daemons/log_analyser.rb is the entry point for the
# log analyser.  It will set $LOG_ANALYSER when it starts
# and before it requires environment.rb which triggers
# rails startup and loads this file.
if $LOG_ANALYSER
  require "file/tail"
  require "inifile"
  require "graticule"

  plugin_lib = "#{File.dirname(__FILE__)}/lib"
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
  require "#{plugin_lib}/daemons/analyser_support"
end
