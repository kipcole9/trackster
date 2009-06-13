with_tag(:div, :id => "user_#{user['id']}", :class => "user clearfix") do
  store image_tag(user.contact.photo(:avatar)) if user.contact && user.contact.photo?
  h4 user.name
  p user.email
end