# This is the main summary page of reporting
include "reports/graphs/pageview_graph"
include 'reports/widgets/new_v_returning'
include "reports/top_ten/pageview_top_10"
column :width => 6 do
  include "reports/top_ten/referrer_top_10"
end
column :width => 6 do
  include "reports/top_ten/search_terms_top_10"
end



