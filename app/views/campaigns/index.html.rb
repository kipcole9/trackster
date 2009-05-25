panel t('panels.campaign_index'), :flash => true do  
  block do
    search t("search"), :id => "campaignSearch", :replace => "campaign", :url => campaign_url
    render_list @campaigns, :partial => 'campaign_summary', :buttons => :all
    store will_paginate
  end
end
