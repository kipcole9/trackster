page do
  column :width => 9 do
    store yield
  end

  column :width => 3 do
    if @contact
      store render 'contacts/about'
      store render 'contacts/bio'   
      store render 'contacts/important_dates'
    end
    store render 'contacts/navigation'

  end

end
