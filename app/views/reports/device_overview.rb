# This is the summary of devices
include "reports/graphs/pageview_graph"
clear do
  column :width => 6 do
    include "reports/graphs/device_pie_graph"
  end
  column :width => 6 do
    include "reports/graphs/os_pie_graph"
  end
end
clear do
  column :width => 6 do
    include "reports/graphs/windows_version_graph"
  end
  column :width => 6 do
    # include "reports/os_pie_graph"
  end
end

