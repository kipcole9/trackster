panel t('.search_terms_top_10')  do
  block do
    store Track.page_views.by(:referrer).filter('referrer IS NOT NULL').limit(10).order('count DESC').all.to_table
  end
end