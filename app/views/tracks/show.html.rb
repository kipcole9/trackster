clear do
  column :width => 6 do
    panel 'panels.chart_1' do
      block do
        store FlashChart.new('caerus.swf').to_html
      end
    end
  end
  column :width => 6 do
    panel 'panels.chart_2' do
      block do
        store FlashChart.new('caerus.swf').to_html
      end
    end    
  end

end
  
clear do
  column :width => 8 do
    include 'emails_opened'
    include 'emails_clicked'
  end
  
  column :width => 4 do
    include "emails_summary"
	end
end