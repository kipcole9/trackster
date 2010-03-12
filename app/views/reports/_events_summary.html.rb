panel t('reports.name.events_summary'), :class => 'table'  do
  block do
    @events_summary ||= resource.events_summary(params)
    if @events_summary.empty?
      h3 t('no_events_yet')
    else
      store @events_summary.to_table
    end
  end
end