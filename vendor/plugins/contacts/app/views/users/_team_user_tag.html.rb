with_tag(:li, :class => :tag, :id => "team_#{team['id']}_user_#{user['id']}") do
  store content_tag(:a, user.name, :href => user_url(user))
  store link_to_remote(image_tag('/images/icons/cancel_bw.png'), :url => team_member_url(team, user), :method => :delete, :title => t('.remove_user_from_team'), :confirm => false)
end