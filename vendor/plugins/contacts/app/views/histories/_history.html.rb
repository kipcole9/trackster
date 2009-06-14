# Note the hack retrieving the created_by user.  Normally this should be user.created_by
# but for some reason, at least in development mode, the reload of the user class doesn't happen properly if the
# access is via association (NoMethod errors)
with_tag(:li, :id => "history_#{history['id']}") do
  create_by = User.find_by_id(history['created_by']).name
  p "#{create_by} #{history.transaction} #{history.historical_type} on #{history.created_at.to_s(:short)}"
end