panel t('.campaign_clicks', :time_group => time_group_t, :time_period => time_period_t_for_graph), :class => 'table'  do
  block do
    campaign_clicks = resource.campaign_clicks(params).all
    if campaign_clicks.empty?
      h3 t('no_impressions_yet')
    else
      store campaign_clicks.to_table
    end
  end
end
