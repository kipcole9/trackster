panel t('dashboards.search_terms_top_10')  do
  block do
    begin
      store Track.page_views.by(:search_terms).filter('search_terms IS NOT NULL').limit(10).order('count DESC').all.to_table
    rescue
      store t('dashboards.no_search_terms_found')
    end
  end
end