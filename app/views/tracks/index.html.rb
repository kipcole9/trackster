clear do
  column :width => 12 do
    panel 'panels.chart_1', :flash => true do
      block do
        store @tracks.to_table
      end
    end
  end
end
