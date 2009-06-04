page do
  clear do
    column :width => 8 do
      store yield
    end
  
    column :width => 4 do
      if params[:action] == 'index' && (current_user.has_role?(Role::ADMIN_ROLE) || current_user.has_role?(Role::ACCOUNT_ROLE))
        include '/users/index'
      end
  	end
  end
end
