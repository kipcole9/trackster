@campaign_summary ||= @campaign.campaign_summary(params).all
clear do
  column :width => 9, :class => 'main' do
    include "campaigns/campaign_impressions_graph_by_day"
    include "campaigns/campaign_overview"
    include "campaigns/campaign_impressions"                
    include "campaigns/campaign_clicks"
    clear do
      column :width => 6 do
        include "campaigns/email_client_overview"
      end
      column :width => 6 do
        include "campaigns/email_client_graph"
      end
    end    
  end
  
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
  end
end
