class BackgroundsController < TracksterResources
  unloadable
  belongs_to      :contact, :singleton => true
  
  def create
    create! do |success, failure|
      success.html { redirect_back_or_default }
    end
  end

end
