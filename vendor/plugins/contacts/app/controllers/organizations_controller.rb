class OrganizationsController < ContactsController
  unloadable
  
  
  def create
    @contact = Organization.new(params[:organization])
    @contact.created_by = current_user
    create! do |success, failure|
      success.html { redirect_back_or_default }
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
