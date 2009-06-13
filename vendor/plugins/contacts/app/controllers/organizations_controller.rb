class OrganizationsController < ApplicationController
  
  def autocomplete
    query = params[:input]
    results = Organization.name_like(query)
    respond_to do |format|
      format.json do
        suggestions = {:results => results.map{|r| {:id => r["id"], :value => r.name}}}
        RAILS_DEFAULT_LOGGER.debug suggestions.inspect
        render :json => suggestions
      end
    end
  end
  
  
end
