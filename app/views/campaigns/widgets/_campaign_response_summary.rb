panel t("campaigns.reports.#{params[:action]}", :time_group => time_group_t, :time_period => time_period_t_for_graph), :class => 'table'  do
  block do
    # TODO This can be very expensive if lots of contacts in a campaign. However
    # it appears MySQL won't allow a condition on a derived column (at least when its got conditions?)
    response_summary ||= resource.campaign_contacts_summary(params).all
    if response_summary.empty?
      h3 t('no_data_yet')
    else
      store response_summary.to_table
    end
  end
end



# Show when first opened and how long after campaign active that was
# And last time clicked
