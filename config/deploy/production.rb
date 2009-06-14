set :deploy_to, "/u/apps/#{application}/production"
set :rails_env, "production"
set :tracker,   "#{release_path}/public/javascripts/tracker_packaged.js"
set :branch, "vie"

