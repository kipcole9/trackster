# The search engine database is maintained in an open source
# format that we need to refresh from time-to-time
namespace :trackster do

  desc "Import browscap"
  task(:import_browscap => :environment) do
    if Rails.env == 'development'
      DIR = "#{Rails.root}/vendor/plugins/browscap/lib"
      `rm #{DIR}/browscap.ini`
      `cd #{DIR} && curl http://browsers.garykeith.com/stream.asp?BrowsCapINI >browscap.ini`        
    end
  end
  
  
end
