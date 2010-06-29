xml.data do
  xml.variable :name => params[:action] do
    @report.each do |row|
      xml.row do
        row.attributes.each do |attr, value|
          xml.column value
        end
      end
    end
  end 
end
