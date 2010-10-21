panel t('reports.name.os_pie_graph', :time_group => time_group_t, :time_period => time_period_t_for_graph)  do
  block do
    @visits_by_os ||= resource.visits_by_os(params).all
    if @visits_by_os.empty?
      h3 t('reports.no_visits_recorded')
    else
      visits_by_os = collapse_data(@visits_by_os, :os_name, :visits)
      store visits_by_os.to_chart(:visits, :os_name, :tooltip => "#label#\nVisits: #val# (#percent#)", :type => :pie)
    end
  end
end
