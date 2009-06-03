# The search engine database is maintained in an open source
# format that we need to refresh from time-to-time
namespace :trackster do

  desc "Import javascript-based search engine database"
  task(:import_search_engine_list => :environment) do
    destination = "#{Rails.root}/tmp/gase.js"
    `curl http://www.antezeta.com/j/gase.js > #{destination}`
    `cat #{Rails.root}/lib/analytics/search_engines_base.js >>#{destination}`
    SearchEngine.import_javascript_list(destination)
    TrafficSource.import_search_engines
  end
  
  
end