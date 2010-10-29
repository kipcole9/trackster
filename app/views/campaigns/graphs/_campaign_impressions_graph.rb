panel t('campaigns.reports.impressions_graph', :time_group => time_group_t, :time_period => time_period_t_for_graph)  do
  block do
    impressions = resource.send("campaign_impressions_by_#{time_group}", params).all
    if impressions.empty?
      h3 t('no_impressions_yet')
    else
      store impressions.to_chart(:impressions, time_group,
        :time_group => time_group,
        :period => params[:period],
        :linearize => true,
        :tooltip => "Day: #x_label#\nImpressions: #val#",
        :weekend_plot_bands => true)
    end
  end
end


