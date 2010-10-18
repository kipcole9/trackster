panel t(".#{params[:action]}"), :class => 'table'  do
  block do
    campaign_overview = resource.campaign_overview(params).all
    if campaign_overview.empty?
      h3 t('no_data_yet')
    else
      store campaign_overview.to_table
    end
  end
end