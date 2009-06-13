with_tag(:li, :class => :tag, :id => "group_#{group['id']}_user_#{user['id']}") do
  store content_tag(:a, user.name, :href => user_url(user))
  store link_to_remote(image_tag('/images/icons/cancel_bw.png'), :url => group_member_url(group, user), :method => :delete, :title => t('.remove_user_from_group'), :confirm => false)
end