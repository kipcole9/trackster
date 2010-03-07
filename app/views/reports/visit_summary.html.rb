# This report is invoked for each of the major metrics
# not including loyalty and event metrics
clear do
  column :width => 9, :class => 'main' do
    include 'pageview_graph'
    include "visits_summary"
  end
  
  column  :width => 3, :id => 'nav_block' do
    include 'navigation'
    include 'time_period'
  end
end
