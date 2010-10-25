# Set session cookie domain
if ActionController::Base.session
  ActionController::Base.session[:domain] = ".#{Trackster::Config.host}"
else
  ActionController::Base.session = { :domain => ".#{Trackster::Config.host}" }
end
