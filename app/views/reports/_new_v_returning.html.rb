panel t('reports.name.new_v_returning', :time_group => time_group_t, :time_period => time_period_t), :class => 'table'  do
  block do
    @page_views ||= resource.page_views_by_visit_type(params).all
    if @page_views.empty?
      h3 t('no_page_views_yet')
    else
      total_page_views = resource.total_page_views(params)
      store @page_views.to_table(:percent_of_page_views => total_page_views)
    end
  end
end