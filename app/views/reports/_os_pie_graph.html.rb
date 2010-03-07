panel t('reports.name.os_pie_graph', :time_group => time_group_t, :time_period => time_period_t_for_graph)  do
  block do
    @os_pie_graph ||= resource.visits_by_os(params).all
    if @os_pie_graph.empty?
      h3 t('reports.no_visits_recorded')
    else
      os_pie_graph = collapse_data(@os_pie_graph, :os_name, :visits)
      store os_pie_graph.to_chart(:visits, :os_name, :tooltip => "#label#\nOperating System: #val# (#percent#)", :type => OpenFlashChart::Pie)
    end
  end
end
