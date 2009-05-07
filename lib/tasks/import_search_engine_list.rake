# The search engine database is maintained in an open source
# format that we need to refresh from time-to-time
namespace :trackster do

  desc "Import javascript-based search engine database"
  task(:import_search_engine_list => :environment) do
    `curl http://www.antezeta.com/j/gase.js > #{Rails.root}/tmp/gase.js`
    SearchEngine.import_javascript_list("#{Rails.root}/tmp/gase.js")
  end
  
  
end