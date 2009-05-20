panel t('dashboards.page_views_top_10')  do
  block do
    store Track.page_views(:with_events).by(:url).limit(10).order('page_views DESC').all.to_table
  end
end