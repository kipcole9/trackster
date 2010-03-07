clear do
  column :width => 9, :class => 'main' do
    clear do
      # include "events_graph"
    end
    clear do
      include "events_summary"
    end
  end
  
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
  end
end
