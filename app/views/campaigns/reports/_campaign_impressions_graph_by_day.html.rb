panel t('.impressions_graph_by_day', :time_group => time_group_t, :time_period => time_period_t_for_graph)  do
  block do
    impressions = resource.tracks.impressions.by(:date).ip_filter.between(Period.from_params(params)).active(resource).all
    if impressions.empty?
      h3 t('no_impressions_yet')
    else
      store impressions.to_chart(:impressions, :date, :tooltip => "Day: #x_label#\nImpressions: #val#")
    end
  end
end
