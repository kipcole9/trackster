ActionController::Routing::Routes.draw do |map|
  # Dynamic ajax validations
  map.validate        '/check/:action.:format', :controller => 'validations'

end
