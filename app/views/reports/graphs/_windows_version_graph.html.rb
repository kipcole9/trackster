panel t('reports.name.windows_version_graph', :time_group => time_group_t, :time_period => time_period_t_for_graph)  do
  block do
    @windows_version_graph ||= resource.visits_by_windows_version(params).all
    if @windows_version_graph.empty?
      h3 t('reports.no_visits_recorded')
    else
      windows_version_graph = collapse_data(@windows_version_graph, :os_version, :visits)
      store windows_version_graph.to_chart(:visits, :os_version, :tooltip => "#label#\nVisits: #val# (#percent#)", :type => :pie)
    end
  end
end
