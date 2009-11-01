class Campaign < ActiveRecord::Base
  include       Analytics::Model
  MAGIC_MARKER  = "ZZXZXXZZXZYYXZQQQQ"
  belongs_to    :property
  belongs_to    :account
  has_many      :sessions
  has_many      :tracks
  
  before_create  :create_campaign_code
   
  validates_associated    :property
  validates_presence_of   :property_id

  validates_associated    :account
  validates_presence_of   :account_id
  
  validates_presence_of     :name
  validates_length_of       :name,    :within => 3..150
  validates_uniqueness_of   :name,    :scope => :property_id
  
  validates_numericality_of :cost,          :allow_nil => true  
  validates_numericality_of :bounces,       :allow_nil => true
  validates_numericality_of :unsubscribes,  :allow_nil => true
  validates_numericality_of :distribution,  :allow_nil => true
  
  default_scope :order => 'created_at DESC'
  
  # Supports user_scope method
  named_scope :user, lambda {|user|
    {:conditions => {:property_id => user.properties.map(&:id)} }
  }
  
  def landing_page_html=(html)
    html.class.name == "Tempfile" ? super(html.read) : super(html)
  end
  
  # Remove leading and trailing '/'
  def image_directory=(directory)
    super(directory.sub(/\A\//,'').sub(/\/\Z/,'')) unless directory.blank?
  end
  
  def email_html=(html)
    html_text = html.class.name == "Tempfile" ? html.read : html
    super(html_text) unless html_text.blank?
  end
  
  def relink_email_html!(&block)
    return nil if self.email_html.blank?
    
    email = ::Nokogiri::HTML(fix_entities(self.email_html))
    fix_anchors!(email, &block)
    fix_images!(email)    
    add_tracker_link!(email)
    if errors.empty?
      self.email_production_html = email.to_html.gsub(MAGIC_MARKER, self.contact_code)
      self.save
      self
    else
      nil
    end
  end
  
  def fix_anchors!(email, &block)  
    (email/"a").each do |link|
      url = link['href']
      link_content = link.content
      next if url == '#' || url.blank? || url =~ /\Amailto/
      begin
        query_string = URI.parse(url).query
        url = url.sub("?#{query_string}", '') unless query_string.blank?
        new_href = yield(Redirect.find_or_create_from_link(property, url, link_content).redirect_url)
        parameters = [query_string, view_parameters].compact.join('&')
        new_href += '?' + parameters unless parameters.blank?
        link.set_attribute 'href', new_href if new_href
      rescue URI::InvalidURIError => e
        Rails.logger.error "Fix Anchors: Invalid URL error detected: '#{link}'"
        errors.add :email_html, I18n.t('campaigns.bad_uri', :url => link)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Fix Anchors: Active record error: #{e.message}"
        Rails.logger.error "URL was '#{url}'"
        errors.add :email_html, e.message 
      end
    end
  end
  
  def fix_images!(email)  
    (email/"img").each do |link|
      url = link['src']
      next if url == '#'
      begin
        uri = URI.parse(url)
        next if uri.scheme
        new_url = [property.url, image_directory, url].compact.join('/')
        link.set_attribute 'src', new_url
      rescue URI::InvalidURIError => e
        Rails.logger.error "Fix Images: Invalid URL: '#{link}'"
        errors.add :email_html, I18n.t('campaigns.bad_uri', :url => link)
      end
    end
  end
  
  def add_tracker_link!(email)
    tracking_node = Nokogiri::XML::Node.new('img', email)
    tracking_node['src'] = [Trackster::Config.tracker_url, open_parameters].join('?')
    email.css("body").first.add_child(tracking_node)
  end
  
private
  def create_campaign_code
    token = nil
    until token && !self.class.find_by_code(token)
      token = ActiveSupport::SecureRandom.hex(3)
    end
    self.code = token
    self.medium = 'email'
  end
  
  def campaign_parameters
    params = "utac=#{property.tracker}&utm_campaign=#{self.code}&utm_medium=#{self.medium}"
    params += "&utm_content=#{self.content}" unless self.content.blank?
    params += "&utm_source=#{self.source}" unless self.source.blank?
    params += "&utid=#{MAGIC_MARKER}" unless self.contact_code.blank?
  end
  
  def view_parameters
    campaign_parameters + "&utcat=page&utact=view"
  end
  
  def open_parameters
    campaign_parameters + "&utcat=email&utact=open"
  end
  
  def fix_entities(text)
    text
  end
end
