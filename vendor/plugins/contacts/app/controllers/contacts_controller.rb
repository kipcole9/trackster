class ContactsController < TracksterResources
  unloadable if Rails.env == 'development'
  
  # Because is nicely divides by 2, 3 and 4 which are the common
  # number of columns in our dynamic contact layout
  PER_PAGE        = 24  
  
  respond_to      :html, :xml, :json, :vcard, :xcelsius
  has_scope       :search
  before_filter   :resource, :only => [:show, :update]
  layout          :choose_layout
 
  def show
    @note = @contact.notes.build
    show!
  end

  def create
    create! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end

  def update
    @contact.attributes = params[:person] || params[:organization]
    update! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end

private
  def begin_of_association_chain
    current_account
  end

  def collection
    @contacts ||= end_of_association_chain.paginate(:page => params[:page], :per_page => contacts_per_page, :include => [:emails, :addresses, :websites, :phones])
  end

  def resource
    @contact ||= end_of_association_chain.find(params[:id], :include => [:emails, :addresses, :websites, :phones])
  end
  
  def choose_layout
    case params[:action]
      when 'show', 'index' then 'application'
      else 'contacts'
    end
  end
  
  def contacts_per_page
    params[:per_page] || PER_PAGE
  end

end
