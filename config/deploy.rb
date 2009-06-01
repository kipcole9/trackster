set :application,   "trackster"
set :default_stage, "staging"
set :app_dir,       "/u/apps"
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

role :app, "server.vietools.com"
role :web, "server.vietools.com"
role :db,  "server.vietools.com", :primary => true

after 'deploy:update_code', 'update_config'
after 'deploy:update_code', 'create_production_tracker'
after 'deploy:update_code', 'create_asset_packages'
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
  tracker_debug = 'tracker_debug.js'
  tracker_production = 'tracker.js'
  tracker_directory = "#{release_path}/public/javascripts"
  begin
    production_code = File.read("#{tracker_directory}/#{tracker_debug}")
    production_code.gsub!('console.log','//console.log')
    production_code.sub!('vietools.com:8080','vietools.com')
    File.open("#{tracker_directory}/#{tracker_production}", 'w') do |production_tracker|
      production_tracker.write(production_code)
    end
  rescue Exception => e
    puts "Could not create production tracker: '#{e.message}'"
    run "ls #{release_path}/public/javascripts"
  end
end

# Secure config files
task :update_config, :roles => :app do
  config_dir    = "#{app_dir}/#{application}/config"
  db_config     = "#{config_dir}/database.yml"
  god_config    = "#{config_dir}/trackster.god"
  site_keys     = "#{config_dir}/site_keys.rb"
  mailer_config = "#{config_dir}/mailer.yml"
  browscap      = "#{config_dir}/browscap.ini"
  crossdomain   = "#{config_dir}/crossdomain.xml"
  device_atlas  = "#{config_dir}/device_atlas.json"
  
  run "ln -s #{mailer_config} #{release_path}/config/mailer.yml"
  run "ln -s #{db_config} #{release_path}/config/database.yml"
  run "ln -s #{god_config} #{release_path}/config/trackster.god"    
  run "ln -s #{site_keys} #{release_path}/config/initializers/site_keys.rb"
  run "ln -s #{browscap} #{release_path}/vendor/plugins/browscap/lib/browscap.ini"
  run "ln -s #{crossdomain} #{release_path}/public/crossdomain.xml"
  run "ln -s #{device_atlas} #{release_path}/lib/analytics/device_atlas.json"
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

desc "Start log analyser"
task :start_log_analyser, :roles => :web do
  run <<-EOF
    export RAILS_ENV=#{rails_env}
    cd #{release_path} && lib/daemons/log_analyser_ctl start
  EOF
end

desc "Stop log analyser"
task :stop_log_analyser, :roles => :web do
  run <<-EOF
    cd #{release_path} && lib/daemons/log_analyser_ctl stop
  EOF
end
