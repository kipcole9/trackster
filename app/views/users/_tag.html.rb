# user => the user
# drag => the object we're tagging
user ||= drag
drop_class = drop.class.name.downcase
id = "#{drop_class}_#{drop.id}_user_#{user.id}"
user_text = user.name.blank? ? user.login : user.name
with_tag(:li, :class => :tag, :id => id) do
  store link_to(user_text, user_url(user), :title => user.email)
  store link_to_remote(image_tag('/images/icons/cancel_bw.png'), 
        :url => relate_url(drop.id, :drop => element_from(drop), :drag => element_from(user)), 
        :method => :delete, :confirm => false,
        :html => {:title => t(".remove_user_from_#{drop_class}")})  if current_user.is_administrator?
  end
end