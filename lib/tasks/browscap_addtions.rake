# Upload the application configuration
namespace :trackster do

  desc "Upload configuration"
  task(:upload_browscap_additions) do
    `scp -P 9876 #{Rails.root}/config/browscap/browscap_additions.ini kip@traphos.com:/u/apps/trackster/config`
  end
end
