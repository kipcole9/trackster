clear do
  column :width => 8 do
    include '/campaigns/summary_status'
  end
  
  column :width => 4 do
    include "widgets/tweet"
  	include "prototypes/search"
  	include "calendars/this_month"
	end
end