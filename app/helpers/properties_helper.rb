module PropertiesHelper
  def property_style(property)
    property.description.blank? ? {:style => "display:none"} : {}
  end
  
end