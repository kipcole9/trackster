class PropertiesController < TracksterResources
  layout              :select_template
  respond_to          :html, :xml, :json
  has_scope           :search

  def update
    update! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end
  
  def destroy
    destroy! do |success, failure|
      success.js {render :delete}
    end
  end
  
private
  def begin_of_association_chain
    current_account
  end

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
