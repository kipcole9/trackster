page do
  clear do
    column :width => 8 do
      store yield
    end
  
    column :width => 4, :class => "sidebar help" do
      store yield(:sidebar)
  	end
  end
end
