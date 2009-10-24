# The search engine database is maintained in an open source
# format that we need to refresh from time-to-time
namespace :trackster do

  desc "Import browscap"
  task(:import_browscap => :environment) do
    if Rails.env == 'development'
      DIR = "#{Rails.root}/vendor/plugins/browscap/lib"
      `rm #{DIR}/browscap.ini`
      `cd #{DIR} && curl http://browsers.garykeith.com/stream.asp?BrowsCapINI >browscap.ini`      
    else
      DIR = "/u/apps/trackster/config"
      `cd #{DIR} && wget http://browsers.garykeith.com/stream.asp?BrowsCapINI -O #{DIR}/browscap.ini`
      `ln -s #{DIR}/browscap.ini vendor/plugins/browscap/lib/browscap.ini` rescue nil    
    end
  end
  
  
end
