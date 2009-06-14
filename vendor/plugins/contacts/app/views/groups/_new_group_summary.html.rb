with_tag(:li, :class => "groupMember", :id => "#{group_member_id(group)}") do
  with_tag(:div, :id => "#{group_id(group)}", :class => 'group') do
    store render(:partial => 'group_summary', :locals => {:group => group})
  end
end