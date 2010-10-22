panel t("campaigns.reports.#{params[:action]}", :time_group => time_group_t, :time_period => time_period_t_for_graph), :class => 'table'  do
  block do
    campaign_summary = resource.campaign_summary(params).all
    if campaign_summary.empty?
      h3 t('no_data_yet')
    else
      store campaign_summary.to_table
    end
  end
end