column :width => 9 do
  include "reports/pageview_graph"
  include "reports/pageview_top_10"
  column :width => 6 do
    include "reports/referrer_top_10"
  end
  column :width => 6 do
    include "reports/search_terms_top_10"
  end
end

column  :width => 3 do
  include 'reports/navigation'
  include 'reports/time_period'
end


