panel t('panels.campaign_navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "Campaign" do
        p link_to("Overview")
        p link_to("Impressions")
        p link_to("Clicks-through")
        p link_to("Link destinations")
      end          
    end
  
    accordian do
      accordian_item "Links" do
        p link_to("Web Property Overview", property_report_path(@campaign.property, "overview"))
      end          
    end    
  end
end
