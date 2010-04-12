# The search engine database is maintained in an open source
# format that we need to refresh from time-to-time
namespace :trackster do
  namespace :delayed_job do
    desc "Start delayed job"
    task(:start => :environment) do
      `#{Rails.root}/lib/daemons/delayed_job_ctl start`
    end
  
    desc "Stop delayed job"
    task(:stop => :environment) do
      `#{Rails.root}/lib/daemons/delayed_job_ctl stop`
    end
  end
end
