clear do
  column :width => 9, :class => 'main' do
    clear do
      column :width => 12 do
        include "campaign_impressions_graph"
      end
    end
    clear do
      column :width => 12 do
        include "campaign_summary"
      end
    end
    clear do
      column :width => 6 do
        include "campaign_impressions"
      end
      column :width => 6 do
        include "campaign_clicks"
      end
    end
  end
  
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
  end
end
