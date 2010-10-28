panel t('reports.name.events_summary'), :class => 'table'  do
  block do
    if @report.empty?
      h3 t('no_events_yet')
    else
      store @report.to_table
    end
  end
end