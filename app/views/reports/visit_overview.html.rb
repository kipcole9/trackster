# This is the main summary page of reporting
include "reports/pageview_graph"
# include 'reports/new_v_returning'
include "reports/pageview_top_10"
column :width => 6 do
  include "reports/referrer_top_10"
end
column :width => 6 do
  include "reports/search_terms_top_10"
end



