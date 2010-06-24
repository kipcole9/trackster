panel t("reports.name.#{params[:action]}", :time_group => time_group_t, :time_period => time_period_t), :class => :table  do
  block do
    if @report.empty?
      h3 t('reports.no_visits_recorded')
    else
      @total_visits = @report.map{|v| v.visits.to_i }.sum
      benchmark "visits to table" do
        store @report.to_table(:percent_of_visits => @total_visits)
      end
    end
  end
end