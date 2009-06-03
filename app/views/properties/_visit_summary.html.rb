panel t(".#{params[:action]}"), :class => 'table'  do
  block do
    if @visit_summary.empty? || (@visit.summary.length == 1 && @visit_summary.first.visits == "0")
      h3 t('no_data_yet')
    else
      total_visits = @visit_summary.map{|v| v.visits.to_i }.sum
      store @visit_summary.to_table(:percent_of_visits => total_visits)
    end
  end
end