clear do
  column :width => 9, :class => 'main' do
    clear do
      include "video_graph"
    end
    clear do
      include "video_summary"
    end
  end
  
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
  end
end
