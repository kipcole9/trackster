page do
  clear do
    column :width => 8 do
      store yield
    end
    
    store yield :sidebar
  end
end
