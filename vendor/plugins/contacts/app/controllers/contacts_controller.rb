class ContactsController < TracksterResources
  # unloadable
  has_scope       :search
  before_filter   :resource, :only => [:show, :update]

  def show
    @note = @contact.notes.build
    show!
  end

  def create
    @contact = Contact.new(params[:person] || params[:organization])
    @contact.created_by = current_user
    create! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end

  def update
    @contact.attributes = params[:person] || params[:organization]
    @contact.updated_by = current_user
    update! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end

private
  def begin_of_association_chain
    current_account
  end

  def collection
    @contacts ||= end_of_association_chain.paginate(:page => params[:page], :per_page => params[:per_page], :include => [:emails, :addresses, :websites, :phones])
  end

  def resource
    @contact ||= end_of_association_chain.find(params[:id], :include => [:emails, :addresses, :websites, :phones])
  end

end
