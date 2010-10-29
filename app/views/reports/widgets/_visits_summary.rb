panel t("reports.name.#{params[:action]}", :time_group => time_group_t, :time_period => time_period_t), :class => :table  do
  block do
    @report = resource.visits_summary(params).sort {|a,b| a[params[:action]].to_i <=> b[params[:action]].to_i }
    if @report.empty?
      h3 t('reports.no_visits_recorded')
    else
      @total_visits = @report.map{|v| v.visits.to_i }.sum
      store @report.to_table(:percent_of_visits => @total_visits)
    end
  end
end