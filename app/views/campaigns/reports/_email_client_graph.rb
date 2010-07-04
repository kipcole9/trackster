panel t('.impressions_graph_by_browser')  do
  block do
    impressions = resource.tracks.impressions.by(:email_client).between(Period.from_params(params)).all
    if impressions.empty?
      h3 t('no_impressions_yet')
    else
      new_impressions = collapse_impressions_data(impressions)
      store new_impressions.to_chart(:impressions, :email_client, :tooltip => "#label#\nImpressions: #val# (#percent#)", :type => OpenFlashChart::Pie)
    end
  end
end
