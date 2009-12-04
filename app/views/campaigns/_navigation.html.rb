panel t('panels.campaign_navigation'), :class => 'accordian'  do
  block do
    accordian do
      accordian_item "Campaign" do
        nav link_to("Overview")
        nav link_to("Impressions")
        nav link_to("Clicks-through")
        nav link_to("Link destinations")
      end          
    end
  
    accordian do
      accordian_item "Links" do
        nav link_to("Web Property Overview", property_report_path(@campaign.property, "overview"))
      end          
    end    
  end
end
