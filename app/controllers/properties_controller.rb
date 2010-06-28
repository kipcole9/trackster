class PropertiesController < TracksterResources
  layout              :select_template
  has_scope           :search
  
  def destroy
    destroy! do |success, failure|
      success.js {render :delete}
    end
  end
  
private
  def collection
    @properties ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page])
  end
  
  def select_template
    if params[:action] == 'show'
      'dashboards'
    else
      'properties'
    end
  end

end
