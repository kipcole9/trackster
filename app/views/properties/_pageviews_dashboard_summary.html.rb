panel t('panels.pageviews_summary')  do
  block do
    store sparkline_tag Track.page_views.property(@property).by(:day).all.map(&:page_views), :type => 'area', :height => '40', :background_color => '#ddd', :above_color => 'blue', :upper => '0'
  end
end