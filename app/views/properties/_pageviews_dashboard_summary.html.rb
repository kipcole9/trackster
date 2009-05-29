panel t('panels.pageviews_summary')  do
  block do
    store @property.tracks.page_views.by(:day).between(Track.period_from_params(params)).all.to_sparkline(:page_views)
  end
end