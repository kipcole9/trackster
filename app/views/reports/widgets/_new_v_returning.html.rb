panel t('reports.name.new_v_returning', :time_group => time_group_t, :time_period => time_period_t), :class => 'table'  do
  block do
    new_params = params.dup.merge(:action => 'new_v_returning')
    @new_v_returning_views ||= resource.new_v_returning_summary(new_params).all
    if @new_v_returning_views.empty?
      h3 t('no_page_views_yet')
    else
      total_visits = resource.total_visits(new_params)
      store @new_v_returning_views.to_table(:percent_of_visits => total_visits)
    end
  end
end