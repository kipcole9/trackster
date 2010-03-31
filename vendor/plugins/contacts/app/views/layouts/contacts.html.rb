page do
  column :width => 8 do
    store yield
  end

  column :width => 4 do
    store render 'contacts/navigation'
  end
end
