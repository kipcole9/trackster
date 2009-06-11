panel t('panels.pageviews_summary')  do
  block do
    store @property.page_views_by_day.to_sparkline(:page_views)
  end
end