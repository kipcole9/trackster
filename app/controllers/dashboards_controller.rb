class DashboardsController < ApplicationController
  before_filter   :get_properties, :only => [:index, :show]
  def show
    render :action => 'index'
  end
  
  def index
  
  end
  
private
  def get_properties
    @properties = current_scope(:properties).all
    if @properties.length == 1 && current_user.is_account_user?
      redirect_to property_report_path(@properties.first, 'overview')
    end
  end
  
end
