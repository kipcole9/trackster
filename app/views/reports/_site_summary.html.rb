panel t("reports.name.#{params[:action]}"), :class => 'table'  do
  block do
    if @site_summary.empty?
      h3 t('no_data_yet')
    else
      store @site_summary.to_table
    end
  end
end