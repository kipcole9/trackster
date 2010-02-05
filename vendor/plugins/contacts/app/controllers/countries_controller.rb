class CountriesController < ApplicationController

  def autocomplete
    query = params[:q]
    respond_to do |format|
      format.text do
        suggestions = Country.name_like(query).map{|k, v| v}.join("\n")
        render :text => suggestions
      end
    end
  end

end
