panel t('.impressions_graph_by_day')  do
  block do
    impressions = (@account || @campaign || @property).tracks.impressions.by(:date).between(Period.from_params(params)).all
    if impressions.empty?
      h3 t('no_impressions_yet')
    else
      store impressions.to_chart(:impressions, :date, :tooltip => "Day: #x_label#\nImpressions: #val#")
    end
  end
end
