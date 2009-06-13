with_tag(:li, :id => "history_#{history['id']}") do
  p "#{history.created_by.login} #{history.transaction} #{history.historical_type} on #{history.created_at}"
end