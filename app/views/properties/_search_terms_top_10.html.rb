panel t('dashboards.search_terms_top_10'), :class => 'table'  do
  block do
    begin
      total_search_terms = @property.tracks.visits.between(Track.period_from_params(params)).first.visits
      store @property.tracks.visits.by(:search_terms).limit(10).order('visits DESC').between(Track.period_from_params(params)).all.to_table(:percent_of_visits => total_search_terms)
    rescue
      h3 t('no_search_terms_found')
    end
  end
end