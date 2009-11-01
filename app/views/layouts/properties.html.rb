page do
  clear do
    column :width => 8 do
      store yield
    end
  
    column :width => 4 do
      if (current_user.has_role?(Role::ADMIN_ROLE) || current_user.has_role?(Role::ACCOUNT_ROLE))
        if params[:action] == 'index'
          include '/users/index'
        elsif params[:action] == 'edit'
          include 'edit_navigation'
        end
      end
  	end
  end
end
