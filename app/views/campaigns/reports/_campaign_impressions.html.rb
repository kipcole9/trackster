panel t('.campaign_impressions', :time_group => time_group_t, :time_period => time_period_t_for_graph), :class => 'table'  do
  block do
    campaign_impressions = resource.campaign_impressions(params).all
    if campaign_impressions.empty?
      h3 t('no_impressions_yet')
    else
      store campaign_impressions.to_table
    end
  end
end
