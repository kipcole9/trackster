# Convenience task that should be used in development only.
# The LogAnalyserDaemon object handles this in staging
# or production.
namespace :trackster do
  namespace :log_analyser do
    desc "Start analyser daemon"
    task(:start => :environment) do
      path = "/opt/ruby-enterprise/bin/ruby:#{ENV['PATH']}"
      system "PATH=#{path} #{File.dirname(__FILE__)}/../daemons/log_analyser.rb"
    end
  end
  
  desc "Get staging tracker log file from traphos"
  task(:get_staging_log => :environment) do
    `scp -P 9876 kip@traphos.com:/opt/nginx/logs/tracker_access_staging.log tmp/`
  end

  desc "Get production tracker log file from traphos"
  task(:get_production_log => :environment) do
    `scp -P 9876 kip@traphos.com:/opt/nginx/logs/tracker_access_production.log tmp/`
  end
end