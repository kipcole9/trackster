panel t("campaigns.reports.campaign_funnel", :time_group => time_group_t, :time_period => time_period_t_for_graph), :class => 'table'  do
  block do
    campaign_summary = @report
    if campaign_summary.empty?
      h3 t('no_data_yet')
    else
      funnel = campaign_summary.first.pivot(:distribution, :bounces, :unsubscribes, :deliveries, :impressions, :clicks_through)
      store funnel.to_chart(:value, :category, :type => :funnel, :container_height => '400px')
    end
  end
end