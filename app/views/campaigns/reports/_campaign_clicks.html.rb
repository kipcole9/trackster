panel t('.campaign_clicks'), :class => 'table'  do
  block do
    campaign_clicks = resource.campaign_clicks(resource, params)
    if campaign_clicks.empty?
      h3 t('no_impressions_yet')
    else
      store campaign_clicks.to_table
    end
  end
end
