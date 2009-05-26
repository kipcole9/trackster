panel t('panels.campaign_index'), :flash => true do  
  block do
    search t("search"), :id => "campaignSearch", :replace => "campaign", :url => campaigns_url
    with_tag(:div, :id => 'campaign') do
      store render :partial => 'index'
    end
    store will_paginate
  end
end
