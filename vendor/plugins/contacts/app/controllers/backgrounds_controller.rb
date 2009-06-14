class BackgroundsController < ApplicationController
  before_filter   :retrieve_contact
  before_filter   :retrieve_background
  helper ContactsHelper
  layout 'contacts'
  
  def edit
    
  end
  
  def update
    if @background.update_attributes(params[:background])
      flash[:notice] = I18n.t('backgrounds.updated')
    else
      flash[:error] = I18n.t('background.not_updated')
    end
    redirect_back_or_default('/')
  end
  
private
  def retrieve_contact
    @contact = Contact.find(params[:contact_id])
  end
  
  def retrieve_background
    @background = @contact.background || @contact.background.new
  end
  
end
