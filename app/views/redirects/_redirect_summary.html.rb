h4 link_to(redirect.name, property_redirect_url(@property, redirect.id))
p "#{t('.redirect_to')}: #{link_to redirect.url, redirect.url}"
p "#{t('.redirect_from')}: #{link_to redirector_url(redirect.redirect_url), redirector_url(redirect.redirect_url)}"

with_tag(:div, :class => :buttons, :style => "display:none") do
  store link_to(image_tag('/images/icons/delete.png', :class => :deleteListItem), property_path(@property, redirect), 
                        :method => :delete, :confirm => t('.delete_redirect', :redirect => redirect.name))
  store link_to(image_tag('/images/icons/add.png', :class => :addListItem), new_property_redirect_path(@property))
  store link_to(image_tag('/images/icons/pencil.png', :class => :editListItem), edit_property_redirect_path(@property, redirect))
end