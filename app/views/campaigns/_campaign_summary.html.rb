h4 link_to("#{campaign.name} (#{campaign.code})", campaign_url(campaign.id))
p campaign.description, :style => (campaign.description.blank? ? "display:none" : "")

if current_user.is_administrator?
  with_tag(:div, :class => :buttons, :style => "display:none") do
    store link_to(image_tag('/images/icons/delete.png', :class => :deleteListItem), campaign_path(campaign), 
                          :method => :delete, :confirm => t('.delete_campaign', :property => campaign.name),
                          :remote => :true)
    store link_to(image_tag('/images/icons/add.png', :class => :addListItem), new_campaign_path)
    store link_to(image_tag('/images/icons/pencil.png', :class => :editListItem), edit_campaign_path(campaign))
  end
end

