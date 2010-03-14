panel t('reports.name.referrer_top_10', :time_group => time_group_t, :time_period => time_period_t), :class => 'table'  do
  block do
    total_referrers = resource.total_referrers(params)
    @referrer_top_10 ||= resource.visits_by_referrer(params).limit(10).all
    if @referrer_top_10.empty?
      h3 t('no_referrers_found')    
    else
      store @referrer_top_10.to_table(:percent_of_visits => total_referrers)
    end
  end
end