panel t(".#{params[:action]}", :time_group => time_group_t, :time_period => time_period_t_for_graph), :class => 'table'  do
  block do
    campaign_overview = resource.campaign_overview(params).all
    if campaign_overview.empty?
      h3 t('no_data_yet')
    else
      store campaign_overview.to_table
    end
  end
end