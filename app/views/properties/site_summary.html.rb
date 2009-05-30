clear do
  column :width => 9, :class => 'main' do
    clear do
      column :width => 12 do
        include "visits_graph"
      end
    end
    clear do
      column :width => 12 do
        include "site_summary"
      end
    end
  end
  
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
  end
end
