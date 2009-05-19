panel t('dashboards.referrer_top_10')  do
  block do
    referrers = Track.visits.by(:referrer).filter('referrer IS NOT NULL').limit(10).order('count DESC').all
    if referrers.empty?
      store t('.no_referrers_found')
    else
      store referrers.to_table
    end
  end
end