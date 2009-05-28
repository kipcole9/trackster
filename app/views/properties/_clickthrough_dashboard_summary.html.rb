panel t('panels.clickthrough_summary')  do
  block do
    store sparkline_tag Track.clicks_through.property(@property).by(:day).all.to_sparkline(:clicks_through)
  end
end