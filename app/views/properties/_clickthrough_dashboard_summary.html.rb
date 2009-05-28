panel t('panels.clickthrough_summary')  do
  block do
    store sparkline_tag Track.clicks_through.property(@property).by(:day).all.map(&:clicks_through), :type => 'area', :height => '40', :background_color => '#ddd', :above_color => 'blue', :upper => '0'
  end
end