with_tag(:li, :class => "team_member", :id => "teamMember_#{@team['id']}") do
  with_tag(:div, :id => @team_id, :class => :team) do
    store render(:partial => 'team_summary', :locals => {:team => @team})
  end
end