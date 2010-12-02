panel t('panels.campaign_navigation') do
  block do
    accordion :id => 'report_navigation' do
      accordion_item "Campaigns" do
        nav report_link("campaign_summary")
        nav report_link("campaign_content")
        nav report_link("campaign_contacts_summary")
        nav report_link("campaign_click_map")
        nav report_link("campaign_funnel")
      end
      accordion_item "Clicks" do
        nav report_link("campaign_clicks_by_url")
        nav report_link("campaign_clicks_by_link_text")
        nav report_link("campaign_clicks_by_email_client")
      end          
    end   
  end
end
