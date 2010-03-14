panel t("reports.name.#{params[:action]}", :time_group => time_group_t, :time_period => time_period_t), :class => 'table'  do
  block do
    @entry_pages ||= resource.entry_exit_summary(params).all
    if @entry_pages.empty?
      h3 t('no_page_views_yet')
    else
      total_page_views = resource.total_page_views(params)
      store @entry_pages.to_table(:percent_of_page_views => total_page_views)
    end
  end
end