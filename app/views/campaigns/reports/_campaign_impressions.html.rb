panel t('.campaign_impressions'), :class => 'table'  do
  block do
    impressions_summary = resource.tracks.impressions.open_rate.deliveries.cost.cost_per_impression.by(:campaign_name).all
    if impressions_summary.empty?
      h3 t('no_impressions_yet')
    else
      store impressions_summary.to_table
    end
  end
end
