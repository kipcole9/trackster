ActionController::Routing::Routes.draw do |map|
  # Authentication and user management
  map.logout          '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.login           '/login',  :controller => 'user_sessions', :action => 'new'
  
  # map.register        '/register/:activation_code', :controller => 'activations', :action => 'new'
  map.activate        '/activate/:id',    :controller => 'activations',     :action => 'create'
  map.reset_password  '/reset_password',  :controller => 'password_resets', :action => 'new'
  map.update_password '/update_password', :controller => 'password_resets', :action => 'edit'
  map.signup          '/signup',          :controller => 'users',           :action => 'new'

  # Resources
  map.resources :users
  map.resources :accounts
  map.resources :user_sessions
  map.resources :password_resets
end