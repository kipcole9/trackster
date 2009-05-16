panel t('dashboards.pageview_graph')  do
  block do
    store Property.all.to_chart(:a, :b)
  end
end