page do
  clear do
    column :width => 9, :id => 'main' do
      store yield
    end

    column  :width => 3, :id => 'navigation' do
      include 'reports/navigation/export'
      include 'campaigns/navigation'
      include 'reports/navigation/time_period'
    end
  end
end
