class PeopleController < ContactsController
  unloadable
  
  def new
    @contact = Person.new
    new!
  end
  
  def create
    @contact = Person.new(params[:person])
    @contact.created_by = current_user
    create! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end


end