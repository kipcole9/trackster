class Redirect < ActiveRecord::Base
  belongs_to                    :account
  has_many                      :events
  before_validation_on_create   :create_redirect_url 
  
  validates_associated      :account
  validates_presence_of     :account_id
  
  validates_presence_of     :name
  validates_length_of       :name,    :within => 1..250
  
  validates_presence_of     :url
  validates_length_of       :url,     :within => 5..250
  validates_uniqueness_of   :url,     :scope => :account_id
  validates_format_of       :url,     :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix
  
  validates_numericality_of :value, :allow_nil => true

  DEFAULT_CATEGORY_ACTION   = ['page', 'view']
  DEFAULT_DOCTYPE           = 'html'
  
  attr_reader              :parsed_url

  named_scope :search, lambda {|criteria|
    search = "%#{criteria}%"
    {:conditions => ['name like ? or url like ?', search, search ]}
  }

  def self.find_or_create_from_link(base_url, url, link_content)
    return nil if url.blank?
    absolute_url = get_absolute_url(base_url, url) 
    account = Account.current_account
    category, action = category_and_action_from(url)
    redirect = account.redirects.find_by_url(absolute_url) ||
               account.redirects.create!(
                      :url        => absolute_url, 
                      :name       => redirect_name_from(link_content, absolute_url),
                      :category   => category,
                      :action     => action
               )
    redirect
  end
  
  def self.category_and_action_from(url)
    doctype = (docpath = parsed_url(url).path.split('/').last) ? docpath.split('.').last : DEFAULT_DOCTYPE
    return I18n.t("doctypes.#{doctype}", :default => lambda{|z, y| DEFAULT_CATEGORY_ACTION})
  end
  
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
  
  def self.redirect_name_from(link_content, url)
    link_content.try(:strip).blank? ? name_from_url(url) : link_content.strip
  end
  
  def self.parsed_url(url)
    URI.parse(url)
  end
  
  def self.name_from_url(url)
    path = parsed_url(url).path
  end
  
  def self.get_absolute_url(base_url, url)
    if parsed_url(url).scheme
      url
    else
      [base_url, url.without_slash].compact.join('/').gsub('//','/')
    end
  end
  
end
