class Phone < ActiveRecord::Base
  unloadable if Rails.env == 'development'  
  belongs_to          :contact
  
  # These days a phone number can be pretty much anything - ie. Skype IDs, ....
  # validates_format_of :number, :with => /\A\s*\+?[\d\(\)\-\s]+\Z/i

  def number=(n)
    n.blank? ? nil : super
  end

end
