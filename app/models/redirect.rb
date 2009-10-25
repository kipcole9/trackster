class Redirect < ActiveRecord::Base
  belongs_to                    :account
  belongs_to                    :property
  has_many                      :events
  before_validation_on_create   :create_redirect_url 
  
  validates_associated      :account
  validates_presence_of     :account_id
  
  validates_associated      :property
  validates_presence_of     :property_id
  
  validates_presence_of     :name
  validates_length_of       :name,    :within => 1..250
  validates_uniqueness_of   :name,    :scope => :property_id
  
  validates_presence_of     :url
  validates_length_of       :url,     :within => 5..200
  validates_uniqueness_of   :url
  validates_format_of       :url,     :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
  
  validates_numericality_of :value, :allow_nil => true
  
  
  def self.find_or_create_from_link(property, url)
    return nil if url.blank?
    absolute_url = property.get_absolute_url(url)
    redirect = property.redirects.find_by_url(absolute_url) || 
               property.redirects.create!(
                  :url => absolute_url, 
                  :name => name_from_url(absolute_url),
                  :account => property.account,
                  :property => property)
    redirect
  end
      
private
  # Create a random token for the redirect url
  # and ensure it is not in use already. This will probably
  # never loop, but just to be sure......
  def create_redirect_url
    token = nil
    until token && !self.class.find_by_redirect_url(token)
      token = ActiveSupport::SecureRandom.hex(3)
    end
    self.redirect_url = token
  end
    
  def self.name_from_url(url)
    path = URI.parse(url).path
  end
  
end
