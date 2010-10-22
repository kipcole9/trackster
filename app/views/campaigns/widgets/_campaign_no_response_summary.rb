panel t("campaigns.reports.campaign_no_response_summary", :time_group => time_group_t, :time_period => time_period_t_for_graph), :class => 'table'  do
  block do
    # TODO This can be very expensive if lots of contacts in a campaign. However
    # it appears MySQL won't allow a condition on a derived column (at least when its got conditions?)
    no_response_summary ||= resource.campaign_no_response_summary(params).all
    if no_response_summary.empty?
      h3 t('no_data_yet')
    else
      store no_response_summary.to_table(:exclude => 'clicks_through')
    end
  end
end
