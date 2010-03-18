page do
  column :width => 9 do
    store yield
  end

  column :width => 3 do
    store render 'navigation'
    store render 'bio'
  end

end
