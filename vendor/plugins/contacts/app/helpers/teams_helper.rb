module TeamsHelper
  
  def teams_in_groups
    @team_groups ||= @teams.group_by(&:parent_id)
  end
  
  def teams(key)
    teams_in_groups[key].each do |team|
      li_class = key.nil? ? 'root' : 'team_member'
      with_tag(:li, :class => li_class, :id => "teamMember_#{team['id']}") do
        with_tag(:div, :class => :team, :id => "team_#{team['id']}") do
          store render(:partial => 'team_summary', :locals => {:team => team})
        end
        if has_subteams?(team)
          with_tag(:ul, :class => :teams) do
            teams(team['id'])
          end
        end
      end
    end
  end
  
  def has_subteams?(team)
    teams_in_groups[team['id']]
  end
end
