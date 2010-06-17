# Upload any browscap local additions.  When uploaded the
# Chef recipe will notice that an update has been supplied
# It will combine with the existing browscap master and
# restart the Collector service
namespace :trackster do
  desc "Upload browscap additions"
  task(:upload_browscap_additions) do
    `scp -P 9876 #{Rails.root}/config/browscap/browscap_additions.ini kip@917rsr.traphos.com:/srv/data`
  end
end
