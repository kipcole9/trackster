panel t('dashboards.search_terms_top_10'), :class => 'table'  do
  block do
    begin
      store @property.tracks.visits.by(:search_terms).filter('search_terms IS NOT NULL').limit(10).order('count DESC').between(Track.period_from_params(params)).all.to_table
    rescue
      store t('dashboards.no_search_terms_found')
    end
  end
end