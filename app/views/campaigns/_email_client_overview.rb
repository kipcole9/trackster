panel t('campaigns.impressions_by_browser'), :class => 'table sixcol'  do
  block do
    impressions = (@campaign || @property).tracks.impressions.by(:browser).between(Track.period_from_params(params)).all
    impressions.reject!{|item| item[:impressions] == 0 }
    if impressions.empty?
      h3 t('no_impressions_yet')
    else
      store impressions.to_table
    end
  end
end
