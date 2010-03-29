class OrganizationsController < ContactsController
  unloadable
  
  def index
    index! do |success, failure|
      success.html { render 'contacts/index' }
    end
  end
    
  def autocomplete
    query = params[:q]
    results = Organization.name_like(query)
    respond_to do |format|
      format.text do
        suggestions = results.map{|r| r.name}.join("\n")
        RAILS_DEFAULT_LOGGER.debug suggestions.inspect
        render :text => suggestions
      end
    end
  end
  
  
end
