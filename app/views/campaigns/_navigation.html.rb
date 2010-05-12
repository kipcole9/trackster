panel t('panels.campaign_navigation') do
  block do
    accordion :id => 'campaign_navigation' do
      accordion_item "Campaign" do
        nav link_to("Overview")
        nav link_to("Impressions")
        nav link_to("Clicks-through")
        nav link_to("Link destinations")
      end          
    end   
  end
end
