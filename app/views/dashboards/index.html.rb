clear do
  column :width => 8 do
    panel t('panels.dashboard'), :flash => true  do
      block do
        store "This is the index page for analytics"
      end
    end
  end

  column :width => 4 do
    # Sidebar stuff
	end
end
