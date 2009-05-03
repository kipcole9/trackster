module RelatesHelper
  def relationship_partial_for(object)
    "#{object.class.name.downcase.pluralize}/tag"
  end
  
  def tag_element_for(drag, drop)
    "#{drop.class.name.downcase}_#{drop.id}_#{drag.class.name.downcase}_#{drag.id}"
  end
  
end
