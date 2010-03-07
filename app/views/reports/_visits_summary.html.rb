panel t("reports.name.#{params[:action]}", :time_group => time_group_t, :time_period => time_period_t), :class => :table  do
  block do
    @visits_summary ||= resource.visits_summary(params).all
    if @visits_summary.empty?
      h3 t('reports.no_visits_recorded')
    else
      total_visits = @visits_summary.map{|v| v.visits.to_i }.sum
      store @visits_summary.to_table(:percent_of_visits => total_visits)
    end
  end
end