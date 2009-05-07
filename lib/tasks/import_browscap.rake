# The search engine database is maintained in an open source
# format that we need to refresh from time-to-time
namespace :trackster do

  desc "Import javascript-based search engine database"
  task(:import_search_engine_list => :environment) do
    if Rails.env == 'development'
      DIR = "#{Rails.root}/vendor/plugins/browscap/lib"
      `rm #{DIR}/browscap.ini`
      `cd #{DIR} && wget http://browsers.garykeith.com/stream.asp?BrowsCapINI -O browscap.ini`      
    else
      DIR = "/u/apps/trackster/config"
      `cd #{DIR} && wget http://browsers.garykeith.com/stream.asp?BrowsCapINI -O browscap.ini`
      `ln -s #{DIR}/browscap.ini vendor/plugins/browscap/lib/browscap.ini`      
    end
  end
  
  
end
