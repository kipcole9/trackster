panel t('panels.pageviews_summary')  do
  block do
    store Track.page_views.property(@property).by(:day).between(Track.period_from_params(params)).all.to_sparkline(:page_views)
  end
end