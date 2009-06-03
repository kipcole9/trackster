panel t('.campaign_clicks'), :class => 'table'  do
  block do
    impressions_summary = (@campaign || @property).tracks.impressions.clicks_through.cost.click_through_rate.cost_per_click.by(:campaign_name).all
    if impressions_summary.empty?
      h3 t('no_impressions_yet')
    else
      store impressions_summary.to_table
    end
  end
end
