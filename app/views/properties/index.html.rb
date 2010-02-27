panel t('panels.property_index'), :flash => true do  
  block do
    search t("search"), :id => "propertySearch", :replace => "property", :url => properties_url
    with_tag(:div, :id => 'property') do
      include 'index'
    end
  end
end
