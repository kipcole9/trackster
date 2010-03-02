# Upload the application configuration
namespace :trackster do

  desc "Upload configuration"
  task(:upload_config) do
    `scp -P 9876 #{Rails.root}/config/trackster_config.yml kip@traphos.com:/u/apps/trackster/config`
  end
  
  desc "Upload newrelic config"
  task(:upload_newrelic) do
    `scp -P 9876 config/newrelic.yml kip@traphos.com:/u/apps/trackster/config/newrelic.yml`
  end
  
end
