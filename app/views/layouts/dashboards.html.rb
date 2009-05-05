page do
  clear do
    column :width => 3 do
      include "emails_dashboard_summary"
    end
    column :width => 3 do
      include "clickthrough_dashboard_summary"
    end
    column :width => 3 do
      include "pageviews_dashboard_summary"
  	end
  	column :width => 3 do
  	  include "visitors_dashboard_summary"
	  end
  end
  clear do
    column :width => 12 do
      include "pageview_graph"
    end
  end
  clear do
    column :width => 12 do
      include "pageview_top_10"
    end
  end
  clear do
    column :width => 6 do
      include "referrer_top_10"
    end
    column :width => 6 do
      include "search_terms_top_10"
    end
  end
end
