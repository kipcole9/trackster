page do
  column :width => 9 do
    store yield
  end

  column :width => 3 do
    if @contact
      store render 'about'
      store render 'bio'   
      store render 'important_dates'
    end
    store render 'navigation'

  end

end
