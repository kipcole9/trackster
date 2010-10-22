panel t('reports.name.page_views', :time_group => time_group_t, :time_period => time_period_t_for_graph)  do
  block do
    @page_views_by ||= resource.send("page_views_by_#{time_group}", params).all
    if @page_views_by.empty?
      h3 t('no_page_views_yet')
    else
      store_chart @page_views_by.to_container_and_script(:page_views, time_group, :tooltip => "At: #x_label#\nViews: #val#", :regression => true)
    end
  end
end