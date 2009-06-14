content_for :jstemplates, form_template_for(:group)
panel t('panels.configure_groups') do  
  block do
    search t(".group_search"), :id => "groupSearch", :search_id => 'groupSearchField', :replace => "group", :url => groups_url
    with_tag(:ul, :id => 'group') do
      store render(:partial => 'new_group_summary', :collection => @groups, :as => :group)
    end
  end
end
