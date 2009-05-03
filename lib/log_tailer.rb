# Main loop for importing tracking records from the server log
# and importing into the database for analysis of site visits
TRACK_PATTERN =  /\A\/tracker.gif.*/
def log_tailer(file, options = {})
  default_options = {:forward => 0}
  options         = default_options.merge(options)
  log_parser      = LogParser.new(:nginx)
  web_analyser    = WebAnalytics.new
  last_log_entry  = [(Event.maximum(:tracked_at) || Time.at(0)), (Session.maximum(:ended_at) || Time.at(0))].max
  File::Tail::Logfile.tail(file, options) do |line|
    entry = log_parser.parse_entry(line)
    if entry[:datetime] > last_log_entry && entry[:url] =~ TRACK_PATTERN
      log_parser.save_web_analytics!(web_analyser, entry) unless web_analyser.is_crawler?(entry[:user_agent])
    end
  end
end