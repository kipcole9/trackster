panel t('dashboards.pageview_graph')  do
  block do
    page_views = @property.tracks.page_views.by(:date).between(1.month.ago..Time.now).all
    if page_views.empty?
      store t('.no_page_views_yet')
    else
      store page_views.to_chart(:page_views, :date, :tooltip => "Date: #x_label#\nViews: #val#", :regression => true)
    end
  end
end