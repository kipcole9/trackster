panel t('reports.name.device_pie_graph', :time_group => time_group_t, :time_period => time_period_t_for_graph)  do
  block do
    @device_pie_graph ||= resource.visits_by_device(params).all
    if @device_pie_graph.empty?
      h3 t('reports.no_visits_recorded')
    else
      device_pie_graph = collapse_data(@device_pie_graph, :device, :visits)
      store device_pie_graph.to_chart(:visits, :device, :tooltip => "#label#\nVisits: #val# (#percent#)", :type => OpenFlashChart::Pie)
    end
  end
end
