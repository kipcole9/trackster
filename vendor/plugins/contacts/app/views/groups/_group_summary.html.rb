h4 "<span>#{group.name}</span>"
p group.description, :style => (group.description.blank? ? "display:none" : "")
with_tag(:ul, :class => :tags) do
  group.users.each do |user|
    store render :partial => 'users/group_user_tag', :locals => {:user => user, :group => group}
  end
end
with_tag(:div, :class => :buttons, :style => "display:none") do
  store link_to_remote(image_tag('/images/icons/delete.png', :class => :deleteGroup), :url => group_url(group), :method => :delete, :confirm => t('.delete_group', :group => group.name))
  store "#{image_tag('/images/icons/add.png', :class => :addGroup)} #{image_tag('/images/icons/pencil.png', :class => :editGroup)}"
end
