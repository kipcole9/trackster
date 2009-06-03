panel t('.campaign_impressions')  do
  block do
    impressions_summary = @property.tracks.impressions.deliveries.cost.cost_per_impression.by(:campaign_name).all
    if impressions_summary.empty?
      h3 t('no_impressions_yet')
    else
      store impressions_summary.to_table
    end
  end
end
