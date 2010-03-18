page do
  # Create and edit a contact
  column :width => 9 do
    yield
  end

  column :width => 3 do
    store render 'navigation'
    store render 'bio'
  end

end
