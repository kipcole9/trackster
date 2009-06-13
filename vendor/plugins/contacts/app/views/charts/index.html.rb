clear do
  column :width => 12 do
    panel 'panels.chart_1' do
      block do
        store @graph
      end
    end
  end
end