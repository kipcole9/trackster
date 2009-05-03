class RelatesController < ApplicationController
  require_role  ["admin", "account holder"]  
  before_filter     :retrieve_both_objects

  # Creates a relationship
  def create
    association_name = @drag.class.name.downcase.pluralize
    if @drop.send("#{association_name}").find_by_id(@drag.id)
      render :action => :highlight_existing_tag
    else
      @drop.send("#{association_name}") << @drag
    end
  end
  
  def destroy
    association_name = "#{@drop.class.name.downcase}_#{@drag.class.name.downcase.pluralize}"
    drag_class = @drag.class.name.downcase
    if relationships = @drop.send("#{association_name}").find(:all, :conditions => ["#{drag_class}_id = ?", @drag.id])
      relationships.map(&:destroy)
    end
  end
  
private
  def retrieve_both_objects
    @drag = find_object(params[:drag])
    @drop = find_object(params[:drop])
  end
  
  def find_object(object)
    class_name, id = object.split('_')
    class_name.classify.constantize.find(id)
  end
end