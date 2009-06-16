with_tag(:div, :class => 'clearfix') do
  store image_tag(property.thumb(:thumb), :class => 'webshot') if property.thumb?
  with_tag(:div, :style => 'float:left') do
    h4 link_to("#{property.name} (#{property.tracker})", property_url(property))
    p property.description, :style => (property.description.blank? ? "display:none" : "")
    p link_to(property.url, property.url)
    with_tag(:ul, :class => :tags) do
      property.users.each do |user|
        store render :partial => 'users/tag', :locals => {:user => user, :drop => property}
      end
    end
  end
end

if current_user.is_administrator?
  with_tag(:div, :class => :buttons, :style => "display:none") do
    store link_to(image_tag('/images/icons/delete.png', :class => :deleteListItem), property_url(property), 
                          :method => :delete, :confirm => t('.delete_property', :property => property.name))
    store link_to(image_tag('/images/icons/add.png', :class => :addListItem), new_property_url)
    store link_to(image_tag('/images/icons/pencil.png', :class => :editListItem), edit_property_path(property))
  end
end