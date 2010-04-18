panel t('panels.campaign_index') do  
  block do
    search t("search"), :id => "campaignSearch", :replace => "campaign", :url => campaigns_url
    with_tag(:div, :id => 'campaign') do
      include 'index'
    end
  end
end
