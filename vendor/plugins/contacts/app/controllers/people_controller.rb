class PeopleController < ContactsController
  def index
    index! do |success, failure|
      success.html { render 'contacts/index' }
    end
  end
end