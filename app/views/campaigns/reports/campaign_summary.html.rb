include "campaigns/widgets/campaign_impressions_graph"
include "campaigns/widgets/campaign_summary"
include "campaigns/widgets/campaign_impressions"
include "campaigns/widgets/campaign_clicks"                
clear do
  column :width => 6 do
    include "campaigns/widgets/email_client_overview"
  end
  column :width => 6 do
    include "campaigns/widgets/email_client_graph"
  end
end    

