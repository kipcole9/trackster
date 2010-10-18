panel t('.campaign_impressions'), :class => 'table'  do
  block do
    campaign_impressions = resource.campaign_impressions(params).all
    if campaign_impressions.empty?
      h3 t('no_impressions_yet')
    else
      store campaign_impressions.to_table
    end
  end
end
