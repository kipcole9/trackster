set :deploy_to, "/u/apps/#{application}/staging"
set :rails_env, "staging"
set :tracker,   "#{release_path}/public/javascripts/tracker_debug_packaged.js"