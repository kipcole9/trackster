class CountriesController < ApplicationController

  def autocomplete
    query = params[:input]
    respond_to do |format|
      format.json do
        suggestions = {:results =>  Country.name_like(query).map{|k, v| {:id => k.to_s, :value => v}}}
        render :json => suggestions
      end
    end
  end

end
