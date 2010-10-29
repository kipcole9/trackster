panel t('campaigns.reports.campaign_clicks_by_email_client', :time_group => time_group_t, :time_period => time_period_t), :class => 'table campaign_clicks'  do
  block do
    @clicks_by_email_client ||= resource.campaign_clicks_by_email_client(params).all.reject{|r| r.clicks_through.to_i == 0}
    if @clicks_by_email_client.empty?
      h3 t('reports.no_clicks_through_yet')
    else
      total_clicks_through = resource.total_clicks_through(params)
      store @clicks_by_email_client.to_table(:percent_of_clicks_through => total_clicks_through)
    end
  end
end