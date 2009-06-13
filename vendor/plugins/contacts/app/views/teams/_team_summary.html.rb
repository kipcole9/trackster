h4 "<span>#{team.name}</span>"
p team.description, :style => (team.description.blank? ? "display:none" : "")
with_tag(:ul, :class => :tags) do
  team.users.each do |user|
    store render :partial => 'users/team_user_tag', :locals => {:user => user, :team => team}
  end
end
with_tag(:div, :class => :buttons, :style => "display:none") do
  unless team.parent_id.nil?
    store link_to_remote(image_tag('/images/icons/delete.png', :class => :deleteTeam), :url => team_url(team), :method => :delete, :confirm => t('.delete_team'))
  end 
  store "#{image_tag('/images/icons/add.png', :class => :addTeam)} #{image_tag('/images/icons/pencil.png', :class => :editTeam)}"
end
