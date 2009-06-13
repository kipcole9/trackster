clear do
  store render :partial => 'contact', :collection => @contacts, :as => 'contact'
end
store will_paginate(@contacts)