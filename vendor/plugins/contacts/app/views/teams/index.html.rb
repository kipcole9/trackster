content_for :jstemplates, form_template_for(:team)
panel t('panels.configure_teams') do  
  block do
    search t(".team_search"), :url => teams_url, :replace => 'team', :id => 'teamSearch'
    with_tag(:ul, :id => 'team') do
      teams(nil)
    end
  end
end
