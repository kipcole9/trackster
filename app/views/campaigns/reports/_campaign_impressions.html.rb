panel t('.campaign_impressions'), :class => 'table'  do
  block do
    impressions_summary = resource.campaign_impressions(resource, params)
    if impressions_summary.empty?
      h3 t('no_impressions_yet')
    else
      store impressions_summary.to_table
    end
  end
end
