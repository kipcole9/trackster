column :width => 9, :class => 'main' do
  include "campaigns/reports/campaign_impressions_graph_by_day"
  include "campaigns/reports/campaign_overview"
  include "campaigns/reports/campaign_impressions"
  include "campaigns/reports/campaign_clicks"                
  clear do
    column :width => 6 do
      include "campaigns/reports/email_client_overview"
    end
    column :width => 6 do
      include "campaigns/reports/email_client_graph"
    end
  end    
end
  
keep :sidebar do
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
  end
end
