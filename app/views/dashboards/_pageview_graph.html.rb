panel t('dashboards.pageview_graph')  do
  block do
    store Track.page_views.by(:date).between(1.month.ago..Time.now).all.to_chart(:page_views, :date, 
                      :tooltip => "Date: #x_label#\nViews: #val#", :text => 'Page Views')
  end
end