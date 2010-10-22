panel t('.impressions_graph_by_browser', :time_group => time_group_t, :time_period => time_period_t_for_graph)  do
  block do
    @email_client_overview ||= resource.email_client_overview(params).all
    if  @email_client_overview.empty?
      h3 t('no_impressions_yet')
    else
      new_impressions = collapse_impressions_data(@email_client_overview)
      store new_impressions.to_chart(:impressions, :email_client, :tooltip => "#label#\nImpressions: #val# (#percent#)", :type => :pie)
    end
  end
end
