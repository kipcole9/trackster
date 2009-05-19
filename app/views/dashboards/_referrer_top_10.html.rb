panel t('dashboards.referrer_top_10')  do
  block do
    referrers = Track.visits.by(:referrer_host).filter('referrer IS NOT NULL').limit(10).order('count DESC').all
    if referrers.empty?
      store t('.no_referrers_found')
    else
      store referrers.to_table(:column_order => [:referrer_host, :visits])
    end
  end
end