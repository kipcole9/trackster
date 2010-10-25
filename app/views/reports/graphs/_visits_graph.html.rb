panel t('reports.name.visits', :time_group => time_group_t, :time_period => time_period_t)  do
  block do
    @visits_graph ||= resource.send("visits_by_#{time_group}", params).all
    if @visits_graph.empty?
      h3 t('reports.no_visits_recorded')
    else
      store @visits_graph.to_chart(:visits, time_group, 
        :tooltip => "At: #x_label#\nVisits: #val#", 
        :regression => true,
        :weekend_plot_bands => true)
    end
  end
end
