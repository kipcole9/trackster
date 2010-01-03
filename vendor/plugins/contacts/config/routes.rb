ActionController::Routing::Routes.draw do |map|
  map.resources :contacts, :has_one => :background
  map.resources :people, :has_one => :background
  map.resources :organizations, :has_one => :background, :collection => {:autocomplete => :get}
  map.resources :notes
  map.resources :tickets
  
  map.resources :teams, :has_many => :members
  map.merge_teams 'teams/:team_to_id/merge/:team_from_id', 
                :controller => 'teams', :action => 'merge', :conditions => { :method => :put }

  map.resources :groups,        :has_many => :members
  map.resource  :calendar
  
  map.resource  :countries,     :collection => {:autocomplete => :get}

end
