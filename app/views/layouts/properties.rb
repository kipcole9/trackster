page do
  clear do
    column :width => 8 do
      store yield
    end
  
    column :width => 4, :class => "sidebar help" do
      include 'property_help'
  	end
  end
end
