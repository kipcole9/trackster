panel t('.impressions_graph_by_local_hour')  do
  block do
    impressions = @property.tracks.impressions.by(:hour).between(Track.period_from_params(params)).all
    if impressions.empty?
      h3 t('no_impressions_yet')
    else
      store impressions.to_chart(:impressions, :hour, :tooltip => "Hour of day: #x_label#\nImpressions: #val#", :label_steps => 1)
    end
  end
end
