xml.data do
  xml.variable :name => params[:action], :time_group => time_group, :from => time_period.first.to_s(:db), :to => time_period.last.to_s(:db) do
    @report.each do |row|
      xml.row do
        row.attributes.each do |attr, value|
          xml.column value, :name => attr
        end
      end
    end
  end 
end
