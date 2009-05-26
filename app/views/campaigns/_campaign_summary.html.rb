h4 link_to("#{campaign.name} (#{campaign.code})", campaign_url(campaign.id))
p campaign.description, :style => (campaign.description.blank? ? "display:none" : "")

with_tag(:div, :class => :buttons, :style => "display:none") do
  store link_to(image_tag('/images/icons/delete.png', :class => :deleteListItem), campaign_url(campaign), 
                        :method => :delete, :confirm => t('.delete_campaign', :property => campaign.name))
  store link_to(image_tag('/images/icons/add.png', :class => :addListItem), new_campaign_url)
  store link_to(image_tag('/images/icons/pencil.png', :class => :editListItem), edit_campaign_path(campaign))
end



