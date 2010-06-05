set :application,   "trackster"
set :default_stage, "staging"
set :app_dir,       "/u/apps"
set :config_dir,    "#{app_dir}/#{application}/config"
set :db_config,     "#{config_dir}/database.yml"
set :god_config,    "#{config_dir}/trackster.god"
set :site_keys,     "#{config_dir}/site_keys.rb"
set :mailer_config, "#{config_dir}/mailer.yml"
set :browscap,      "#{config_dir}/browscap.ini"
set :crossdomain,   "#{config_dir}/crossdomain.xml"
set :device_atlas,  "#{config_dir}/device_atlas.json"
set :app_conf,      "#{config_dir}/trackster_config.yml"
set :newrelic,      "#{config_dir}/newrelic.yml"

require 'capistrano/ext/multistage'


# Use Git source control
set :scm, :git
set :repository, "git@github.com:kipcole9/trackster.git"

# Deploy from master branch by default
set :branch, "master"
#set :scm_verbose, true

set :user, 'kip'
ssh_options[:forward_agent] = true
ssh_options[:port] = 9876
default_run_options[:pty] = true

role :app, "boxster.traphos.com"
role :web, "boxster.traphos.com"
role :db,  "boxster.traphos.com"

after 'deploy:update_code', 'update_config'
after 'deploy:update_code', 'create_production_tracker'
after 'deploy:update_code', 'create_asset_packages'
after 'deploy:update_code', 'symlink_tracker_code'
after 'deploy:update_code', 'migrate_database'

namespace :deploy do
  desc "Restarting passenger with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with passenger"
    task t, :roles => :app do ; end
  end
end

# Take the debug tracker code, comment out the console.log
# statements.  Do this before asset_packager kicks in.
task :create_production_tracker, :roles => :web do
  run <<-EOF
    cd #{release_path} && rake RAILS_ENV=#{rails_env} trackster:build_tracker --trace
  EOF

end

desc "Symlink tracker production javscript"
task :symlink_tracker_code, :roles => :app do  
  run "ln -s #{tracker} #{release_path}/public/_tks.js"
end

# Secure config files
desc "Link production configuration files"
task :update_config, :roles => :app do
  run "ln -s #{mailer_config} #{release_path}/config/mailer.yml"
  run "ln -s #{app_conf}  #{release_path}/config/trackster_config.yml"  
  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "ln -s #{god_config} #{release_path}/config/trackster.god"    
  run "ln -s #{site_keys} #{release_path}/config/initializers/site_keys.rb"
  run "ln -s #{browscap} #{release_path}/vendor/plugins/browscap/lib/browscap.ini"
  run "ln -s #{crossdomain} #{release_path}/public/crossdomain.xml"
  run "ln -s #{device_atlas} #{release_path}/lib/analytics/device_atlas.json"
  run "ln -s #{newrelic} #{release_path}/config/newrelic.yml"
end

desc "Create asset packages for production" 
task :create_asset_packages, :roles => :web do
  run <<-EOF
    cd #{release_path} && rake RAILS_ENV=#{rails_env} asset:packager:build_all
  EOF
end

desc "Run database migrations"
task :migrate_database, :roles => :db do
  run "cd #{release_path} && rake RAILS_ENV=#{rails_env} db:migrate"
end

desc "Update search engines"
task :update_search_engines, :roles => :app do
  run "cd #{current_path} && rake RAILS_ENV=#{rails_env} trackster:import_search_engine_list"
end

desc "Add browscap additions"
task :update_browscap, :roles => :app do
  src_file = File.join(File.dirname(__FILE__), 'browscap', 'browscap_additions.ini')
  `scp -P 9876 #{src_file} kip@traphos.com:/u/apps/trackster/config`
  run "cd #{current_path} && rake RAILS_ENV=#{rails_env} trackster:import_browscap"
end

namespace :log_analyser do
  desc "Start log analyser"
  task :start, :roles => :app do
    run <<-EOF
      export RAILS_ENV=#{rails_env} &&
      cd #{current_path} && lib/daemons/log_analyser_ctl start
    EOF
  end

  desc "Stop log analyser"
  task :stop, :roles => :app do
    run <<-EOF
      export RAILS_ENV=#{rails_env} &&
      cd #{current_path} && lib/daemons/log_analyser_ctl stop
    EOF
  end
end

namespace :delayed_job do
  desc "Start delayed job"
  task :start, :roles => :app do
    run <<-EOF
      export RAILS_ENV=#{rails_env} &&
      cd #{current_path} && lib/daemons/delayed_job_ctl start
    EOF
  end

  desc "Stop delayed job"
  task :stop, :roles => :app do
    run <<-EOF
      export RAILS_ENV=#{rails_env} &&
      cd #{current_path} && lib/daemons/delayed_job_ctl stop
    EOF
  end
end
