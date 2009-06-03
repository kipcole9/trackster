panel t('dashboards.referrer_top_10'), :class => 'table'  do
  block do
    total_referrers = @property.tracks.visits.filter('referrer_host IS NOT NULL').between(Track.period_from_params(params)).first.visits
    referrers = @property.tracks.visits.by(:referrer_host).order('visits DESC').limit(10).between(Track.period_from_params(params)).all
    if referrers.empty?
      h3 t('no_referrers_found')
    else
      store referrers.to_table(:percent_of_visits => total_referrers)
    end
  end
end