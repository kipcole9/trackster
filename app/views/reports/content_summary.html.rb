clear do
  column :width => 9, :class => 'main' do
    clear do
      include "pageview_graph"
    end
    clear do
      include "content_summary"
    end
  end
  
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
    include 'time_period'
  end
end
