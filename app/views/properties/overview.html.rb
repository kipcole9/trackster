clear do
  column :width => 9, :class => 'main' do
    clear do
      column :width => 12 do
        include "pageview_graph"
      end
    end
    clear do
      column :width => 12 do
        include "pageview_top_10"
      end
    end
    clear do
      column :width => 6 do
        include "referrer_top_10"
      end
      column :width => 6 do
        include "search_terms_top_10"
      end
    end
  end
  
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
  end
end

