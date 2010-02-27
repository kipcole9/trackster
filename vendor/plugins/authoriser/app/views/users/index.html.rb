@users ||= User.all
panel t('panels.user_pick_list') do  
  block do
    search t(".user_search"), :id => :userSearch, :search_id => 'userSearchField', :replace => 'userList', 
          :url => users_url()
    with_tag(:div, :id => 'userList') do
      include 'index'
    end
  end
end
