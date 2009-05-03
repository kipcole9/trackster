page do
  clear do
    column :width => 8 do
      store yield
    end
  
    column :width => 4 do
      include "widgets/tweet"
    	include "prototypes/search"
    	include "calendars/this_month"
  	end
  end
end
