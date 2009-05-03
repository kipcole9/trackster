panel t('panels.property_index'), :flash => true do  
  block do
    search t("search"), :id => "propertySearch", :replace => "property", :url => properties_url
    render_list @properties, :partial => 'property_summary', :accepts => :user, :buttons => :all
    store will_paginate
  end
end
