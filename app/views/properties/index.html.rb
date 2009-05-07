panel t('panels.property_index'), :flash => true do  
  block do
    search t("search"), :id => "propertySearch", :replace => "property", :url => properties_url
    with_tag(:div, :id => 'property') do
      store render :partial => 'index'
    end
    store will_paginate
  end
end
