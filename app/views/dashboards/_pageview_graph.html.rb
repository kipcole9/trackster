panel t('dashboards.pageview_graph')  do
  block do
    store Track.page_views.by(:day).between(1.month.ago..Time.now).all.to_chart(:count)
  end
end