# This is the summary of devices
column :width => 9 do
  include "reports/pageview_graph"
  column :width => 6 do
    include "reports/device_pie_graph"
  end
  column :width => 6 do
    include "reports/os_pie_graph"
  end
end

column  :width => 3 do
  include 'reports/navigation'
  include 'reports/time_period'
end
