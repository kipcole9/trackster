panel t('.visit_graph')  do
  block do
    visits = @property.tracks.visits.by(:date).between(Track.period_from_params(params)).all
    if visits.empty? || (visits.size == 1 && visits.first.visits == "0")
      store t('.no_visits_yet')
    else
      store visits.to_chart(:visits, :date, :tooltip => "Date: #x_label#\nVisits: #val#", :regression => true)
    end
  end
end