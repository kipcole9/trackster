page do
  clear do
    column :width => 8 do
      store yield
    end
  
    column :width => 4 do
      include 'edit_navigation'
  	end
  end
end
