panel t('panels.clickthrough_summary')  do
  block do
    store Track.clicks_through.property(@property).by(:day).order('clicks_through DESC').between(Track.period_from_params(params)).all.to_sparkline(:clicks_through)
  end
end