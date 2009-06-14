class ContactsController < ApplicationController
  before_filter   :retrieve_contact, :only => [:update, :show, :edit]
  before_filter   :retrieve_contacts, :only => [:index]
  
  def show
    @note = @contact.notes.build
  end

  def create
    @contact = Person.new(params[:person] || params[:organization])
    @contact.created_by = current_user
    @contact.save ? redirect_to(contact_path(@contact)) : render(:action => :edit)
  end

  def update
    @contact.attributes = params[:person] || params[:organization]
    @contact.updated_by = current_user
    if @contact.save
      flash[:notice] =  "Contact updated sucessfully."
      redirect_to(contact_path(@contact))
    else
      flash.now[:error] =  "Contact could not be updated."
      render :edit
    end
  end
  
  def index
    respond_to do |format|
      format.html
      format.js { render :partial => 'contacts' }
    end
  end
  
private
  def retrieve_contact
   #  @contact = current_account.contacts.find(params[:id])
   @contact = Contact.find(params[:id])
  end
  
  def retrieve_contacts
    conditions = conditions_from_search(params[:search])
    # @contacts = current_account.contacts.paginate(:page => params[:page], :conditions => conditions, :include => [:emails, :addresses, :websites, :phones])
    @contacts = Contact.paginate(:page => params[:page], :conditions => conditions, :include => [:emails, :addresses, :websites, :phones])
  end
  
  def conditions_from_search(search)
    return '' if search.blank?
    conditions = []
    names = search.split(' ').map(&:strip)
    names.each do |name|
      conditions << "given_name LIKE '%#{quote_string(name)}%' OR family_name LIKE '%#{quote_string(name)}%' or name LIKE '%#{quote_string(name)}%'" unless name.blank?
    end
    conditions.join(' OR ')
  end
  
  def quote_string(string)
    ActiveRecord::Base.connection.quote_string(string)
  end
end
