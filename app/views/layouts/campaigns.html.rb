page do
  clear do
    column :width => 8 do
      store yield
    end
  
    column :width => 4 do
      if @campaign.preview_available? && current_user.is_administrator? && !@campaign.email_html.blank?
        include 'edit_navigation'
      end
  	end
  end
end
