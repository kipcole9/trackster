panel t('campaigns.impressions_graph_by_browser')  do
  block do
    impressions = (@campaign || @property).tracks.impressions.by(:browser).between(Track.period_from_params(params)).all
    if impressions.empty?
      h3 t('no_impressions_yet')
    else
      store impressions.to_chart(:impressions, :browser, :tooltip => "#label#\nImpressions: #val# (#percent#)", :type => OpenFlashChart::Pie)
    end
  end
end
