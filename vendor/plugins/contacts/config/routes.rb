ActionController::Routing::Routes.draw do |map|
  map.resources :contacts, :has_one => :background
  map.resources :notes
  map.resources :tickets
  
  map.resources :teams, :has_many => :members
  map.merge_teams 'teams/:team_to_id/merge/:team_from_id', 
                :controller => 'teams', :action => 'merge', :conditions => { :method => :put }

  map.resources :groups,        :has_many => :members
  map.resources :organizations, :collection => {:autocomplete => :get}

  map.resource  :calendar

end
