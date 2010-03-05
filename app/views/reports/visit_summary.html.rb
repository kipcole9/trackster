clear do
  column :width => 9, :class => 'main' do
    include "visit_summary"
  end
  
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
  end
end
