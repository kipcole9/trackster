panel t('panels.campaign_navigation'), :class => 'accordion'  do
  block do
    accordion do
      accordion_item "Campaign" do
        nav link_to("Overview")
        nav link_to("Impressions")
        nav link_to("Clicks-through")
        nav link_to("Link destinations")
      end          
    end   
  end
end
