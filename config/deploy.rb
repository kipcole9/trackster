set :application,   "trackster"
set :default_stage, "staging"
set :app_dir,       "/u/apps"
set :config_dir,    "#{app_dir}/#{application}/config"
set :db_config,     "#{config_dir}/database.yml"
set :site_keys,     "#{config_dir}/site_keys.rb"
set :browscap,      "#{config_dir}/browscap.ini"
set :device_atlas,  "#{config_dir}/device_atlas.json"
set :app_conf,      "#{config_dir}/trackster_config.yml"
set :newrelic,      "#{config_dir}/newrelic.yml"

require 'capistrano/ext/multistage'

# Use Git source control
set :scm, :git
set :repository, "git@github.com:kipcole9/trackster.git"
default_environment["PATH"] = "/opt/ruby-enterprise/bin:$PATH"

# Deploy from master branch by default
set :branch, "master"
set :deploy_via, :remote_cache
#set :scm_verbose, true

set :user, 'www-data'
ssh_options[:forward_agent] = true
ssh_options[:port] = 9876
default_run_options[:pty] = true

role :app, "boxster.traphos.com", "917rsr.traphos.com"
role :web, "boxster.traphos.com", "917rsr.traphos.com"
role :db,  "boxster.traphos.com"

after 'deploy:update_code', 'update_config'
after 'deploy:update_code', 'create_production_tracker'
after 'deploy:update_code', 'create_asset_packages'
after 'deploy:update_code', 'symlink_tracker_code'
after 'deploy:update_code', 'migrate_database'
after 'deploy:update_code', 'fix_ownership'

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
  run "ln -s #{app_conf}  #{release_path}/config/trackster_config.yml"  
  run "ln -s #{db_config} #{release_path}/config/database.yml"  
  run "ln -s #{site_keys} #{release_path}/config/initializers/site_keys.rb"
  run "ln -s #{browscap} #{release_path}/vendor/plugins/browscap/lib/browscap.ini"
  run "ln -s #{device_atlas} #{release_path}/vendor/plugins/analytics/lib/analytics/device_atlas.json"
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

desc "Fix ownership"
task :fix_ownership, :roles => :app do
  run "sudo chown -R www-data:admin #{app_dir}/#{application}"
end