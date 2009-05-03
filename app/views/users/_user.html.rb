with_tag(:div, :id => "user_#{user['id']}", :class => "user clearfix") do
  store image_tag(user.photo(:avatar)) if user && user.photo?
  h4 user.name
  p user.email
end