page do
  clear do
    column :width => 8 do
      store yield
    end
  
    column :width => 4 do
      # Sidebar stuff
  	end
  end
end
