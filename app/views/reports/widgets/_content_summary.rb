panel t("reports.name.#{params[:action]}", :name => params[:action], :time_group => time_group_t, :time_period => time_period_t), :class => :table  do
  block do
    if @report.empty?
      h3 t('reports.no_visits_recorded')
    else
      total_page_views = @report.map{|v| v.page_views.to_i }.sum
      store @report.to_table(:percent_of_page_views => total_page_views)
    end
  end
end