panel t('sites.latency')  do
  block do
    if @latency.empty?
      h3 t('sites.no_latency_found')    
    else
      store @latency.to_chart(:latency, :date)
    end
  end
end