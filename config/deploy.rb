set :application,   "trackster"
set :default_stage, "production"
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

set :user, 'kip'
ssh_options[:forward_agent] = true
ssh_options[:port] = 9876
default_run_options[:pty] = true

role :app,          "boxster.traphos.com",  :passenger    => true
role :app,          "917rsr.traphos.com",   :collector    => true
role :app,          "928gts.traphos.com",   :delayed_job  => true
role :web,          "boxster.traphos.com"
role :db,           "boxster.traphos.com",  :primary      => true

after 'deploy:update_code', 'update_config'
after 'deploy:update_code', 'create_production_tracker'
after 'deploy:update_code', 'create_asset_packages'
after 'deploy:update_code', 'symlink_tracker_code'
after 'deploy:update_code', 'fix_ownership'

namespace :deploy do
  task :restart do 
    restart_passenger 
    restart_collector
    restart_delayed_job
  end 
  
  task :restart_passenger, :only => { :passenger => true } do 
    run "touch #{current_path}/tmp/restart.txt" 
  end 
  
  task :restart_collector, :only => { :collector => true } do 
    sudo "/etc/init.d/collector -w 30 restart"
  end

  task :restart_delayed_job, :only => { :delayed_job => true } do 
    sudo "service delayed_job restart"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with passenger"
    task t, :roles => :web do ; end
  end
end

# Take the debug tracker code, comment out the console.log
# statements.  Do this before asset_packager kicks in.
task :create_production_tracker, :roles => :app do
  run <<-EOF
    cd #{release_path} && rake RAILS_ENV=#{rails_env} trackster:build_tracker
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
  run "ln -s #{device_atlas} #{release_path}/vendor/plugins/analytics/data/device_atlas.json"
  run "ln -s #{newrelic} #{release_path}/config/newrelic.yml"
  run "ln -s #{config_dir}/crossdomain.xml #{release_path}/public/crossdomain.xml"
end

desc "Create asset packages for production" 
task :create_asset_packages, :roles => :app do
  run <<-EOF
    cd #{release_path} && rake RAILS_ENV=#{rails_env} asset:packager:build_all
  EOF
end

desc "Fix ownership"
task :fix_ownership, :roles => :app do
  run "sudo chown -R www-data:admin #{release_path}"
  run "sudo chmod 775 #{release_path}/tmp"
end

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
