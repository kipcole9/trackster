class BackgroundsController < TracksterResources
  unloadable
  belongs_to    :contact
  helper ContactsHelper
  layout 'contacts'
  
  def create
    resource
    create!
  end

private
  def resource
    @contact = current_account.contacts.find(params[:contact_id])
    @background = @contact.background || @contact.build_background
  end
  
  
end
