clear do
  column :width => 9, :class => 'main' do
    include "visits_graph"
    include "site_summary"
  end
  
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
    include 'time_period'
  end
end
