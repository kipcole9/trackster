class Campaign < ActiveRecord::Base
  belongs_to    :property
  has_many      :sessions
  has_many      :tracks
  
  before_create  :create_campaign_code
   
  validates_associated    :property
  validates_presence_of   :property_id

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

  def email_html=(html)
    html.class.name == "Tempfile" ? super(html.read) : super(html)
  end
  
  def relink_email_html!(&block)
    email = Hpricot(email_html)
    fix_anchors!(email, &block)
    fix_images!(email)
    add_tracker_link!(email)
    if errors.empty?
      self.email_production_html = email.to_s
      self.save
    end
    self
  end
  
  def fix_anchors!(email, &block)  
    (email/"a").each do |link|
      url = link['href']
      next if url == '#' || url =~ /\Amailto/
      begin
        query_string = URI.parse(url).query
        url = url.sub("?#{query_string}", '') unless query_string.blank?
        new_href = yield(Redirect.find_or_create_from_link(property, url).redirect_url)
        new_href += '?' + [query_string, campaign_parameters].compact.join('&')
        link.set_attribute :href, new_href if new_href
      rescue URI::BadURIError => e
        errors.add :email_html, I18n.t('campaigns.bad_uri', :url => link)
      rescue ActiveRecord::RecordInvalid => e
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
        link.set_attribute :src, new_url
      rescue URI::BadURIError => e
        errors.add :email_html, I18n.t('campaigns.bad_uri', :url => link)
      end
    end
  end
  
  def add_tracker_link!(email)
    body = (email/"body").innerHTML
    body += "\n<img src='" + [Trackster::Config.tracker_url, campaign_parameters].join('?') + "'>\n"
    (email/"body").innerHTML = body
  end
  
private
  def create_campaign_code
    token = nil
    until token && !self.class.find_by_code(token)
      token = ActiveSupport::SecureRandom.hex(3)
    end
    self.code = token
  end
  
  def campaign_parameters
    "utm_campaign=#{self.code}&utm_medium=email"
  end
end
