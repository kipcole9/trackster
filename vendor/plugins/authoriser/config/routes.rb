ActionController::Routing::Routes.draw do |map|
  # Authentication and user management
  map.logout          '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.login           '/login', :controller => 'user_sessions', :action => 'new'
  
  map.register        '/register', :controller => 'users', :action => 'create'
  map.activate        '/activate/:activation_code', :controller => 'users', :action => 'activate'
  map.change_password '/change_password', :controller => 'users', :action => 'change_password'
  map.update_password '/update_password', :controller => 'users', :action => 'update_password', :conditions => {:method => :put}
  map.signup          '/signup', :controller => 'users', :action => 'new'

  map.resources :users
  map.resources :accounts
  map.resources :user_sessions
end