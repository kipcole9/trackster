# Upload the application configuration
namespace :trackster do

  desc "Upload configuration"
  task(:upload_config => :environment) do
    `scp -P 9876 #{Rails.root}/config/trackster_config.yml kip@traphos.com:/u/apps/trackster/config`
  end
  
  
end
