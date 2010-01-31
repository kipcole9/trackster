column :width => 9 do
  include "pageview_graph"
  include "pageview_top_10"
  column :width => 6 do
    include "referrer_top_10"
  end
  column :width => 6 do
    include "search_terms_top_10"
  end
end

column  :width => 3 do
  include 'navigation'
  include 'time_period'
end


