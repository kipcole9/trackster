panel t('reports.name.search_terms_top_10', :time_group => time_group_t, :time_period => time_period_t), :class => 'table'  do
  block do
    begin
      total_search_terms = resource.total_visits(params)
      store resource.visits_by_search_terms(params).limit(10).all.to_table(:percent_of_visits => total_search_terms)
    rescue
      h3 t('no_search_terms_found')    
    end
  end
end