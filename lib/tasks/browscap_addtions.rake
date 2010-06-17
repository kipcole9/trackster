# Upload any browscap local additions
namespace :trackster do
  desc "Upload configuration"
  task(:upload_browscap_additions) do
    `scp -P 9876 #{Rails.root}/config/browscap/browscap_additions.ini kip@traphos.com:/srv/data`
  end
end
