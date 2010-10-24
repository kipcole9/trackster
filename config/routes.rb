ActionController::Routing::Routes.draw do |map|
  map.resources :relates
  map.resources :campaigns, :member => {:preview => :get, :click_map => :get}
  map.resources :contents
  map.resources :properties do |properties|
    properties.resources :redirects
  end
  
  map.resource :site
  map.resource :dashboard, :member => {:trythis => :get}    # Home paged for logged_in users
  
  # Reporting for analytics
  map.property_report '/properties/:property_id/reports/:action.:format', :controller => 'reports'
  map.campaign_report '/campaigns/:campaign_id/reports/:action.:format',  :controller => 'reports'
  map.account_report  '/reports/:action.:format', :controller => 'reports'
  
  # Redirect - but only for development mode
  # Sinatra app does redirects in the production
  if Rails.env == 'development'
    map.redirect '/r/:id', :controller => 'redirects', :action => 'redirect'
  end

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"
  map.root :controller => "dashboards"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
  map.connect '*url', :controller => "application", :action => 'page_not_found'
end
