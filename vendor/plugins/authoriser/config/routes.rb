ActionController::Routing::Routes.draw do |map|
  # Authentication and user management
  map.logout          '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.login           '/login', :controller => 'user_sessions', :action => 'new'
  
  map.register        '/register/:activation_code', :controller => 'activations', :action => 'new'
  map.activate        '/activate/:id', :controller => 'activations', :action => 'create'
  map.change_password '/change_password', :controller => 'users', :action => 'change_password'
  map.update_password '/update_password', :controller => 'users', :action => 'update_password', :conditions => {:method => :put}
  map.signup          '/signup', :controller => 'users', :action => 'new'

  # Resources
  map.resources :users
  map.resources :accounts
  map.resources :user_sessions
end