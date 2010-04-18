clear do
  float :left do
    img '/images/list_icons/campaign.png', :class => :list_image
  end
  float :left do
    h4 link_to("#{campaign.name} (#{campaign.code})", campaign_path(campaign))
    p campaign.description, :style => (campaign.description.blank? ? "display:none" : "")
  end
end




