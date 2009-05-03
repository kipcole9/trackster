set :default_stage, "staging"
set :app_dir, "/u/apps"
require 'capistrano/ext/multistage'

set :application, "vietools.com"

# Use Git source control
set :scm, :git
set :repository, "git@github.com:kipcole9/trackster.git"

# Deploy from master branch by default
set :branch, "master"
set :deploy_via, :copy
set :scm_verbose, true

set :user, 'kip'
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

role :app, "server.vietools.com"
role :web, "server.vietools.com"
role :db,  "server.vietools.com", :primary => true

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

# Avoid keeping the database.yml configuration in git.
task :copy_database_yml, :roles => :app do
  db_config = "#{app_dir}/#{application}/config/database.yml"
  site_keys = "#{app_dir}/#{application}/config/site_keys.rb"
  run "cp #{db_config} #{release_path}/config/database.yml"
  run "cp #{site_keys} #{release_path}/config/initializers/site_keys.rb"
end