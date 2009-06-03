clear do
  column :width => 9, :class => 'main' do
    clear do
      column :width => 12 do
        include "properties/campaign_impressions_graph"
      end
    end
    clear do
      column :width => 12 do
        include "properties/campaign_summary"
        include "properties/campaign_impressions"                
        include "properties/campaign_clicks"
      end
    end
  end
  
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
  end
end
