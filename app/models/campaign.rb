class Campaign < ActiveRecord::Base  
  MAGIC_MARKER  = "ZZXZXXZZXZYYXZQQQQ"
  REDIRECT_SCHEMES = %w(http https ftp)
  belongs_to    :account
  has_many      :sessions
  has_many      :tracks
  belongs_to    :email_content, :class_name => 'Content', :foreign_key => :content_id
  
  before_create  :create_campaign_code

  validates_associated      :account
  validates_presence_of     :account_id
  
  validates_presence_of     :name
  validates_length_of       :name,    :within => 3..150
  validates_uniqueness_of   :name,    :scope => :account_id
  
  validates_numericality_of :cost,          :allow_nil => true  
  validates_numericality_of :bounces,       :allow_nil => true
  validates_numericality_of :unsubscribes,  :allow_nil => true
  validates_numericality_of :distribution,  :allow_nil => true
  
  default_scope :order => 'created_at DESC'
  
  # Supports user_scope method
  named_scope :user, lambda {|user|
    {:conditions => {:property_id => user.properties.map(&:id)} }
  }
  
  named_scope :search, lambda {|criteria|
    search = "%#{criteria}%"
    {:conditions => ['name like ? or description like ?', search, search ]}
  }

  def email=(c)
    self.content_id = c
    self.content_id_will_change!
  end
  
  def email
    self.email_content.id rescue nil
  end

  def relink_email_html!(&block)
    return nil if (email_content = self.email_content.content).blank?
    html = ::Nokogiri::HTML(fix_entities(email_content))
    fix_anchors!(self.email_content, html, &block)
    fix_images!(self.email_content, html)    
    add_tracker_link!(self.email_content, html)
    if errors.empty?
      self.email_production_html = unfix_entities(html.to_html.gsub(MAGIC_MARKER, self.contact_code))
      self.save!
      self
    else
      nil
    end
  end
  
  def fix_anchors!(email_content, email, &block)  
    (email/"a").each do |link|
      url = link['href']
      link_content = link.content
      next if url == '#' || url.blank? || url =~ /\Amailto/
      begin
        parsed_url = URI.parse(url)
        query_string = parsed_url.query
        next unless REDIRECT_SCHEMES.include? parsed_url.scheme
        url = url.sub("?#{query_string}", '') unless query_string.blank?
        new_href = yield(Redirect.find_or_create_from_link(self.email_content, url, link_content).redirect_url)
        parameters = [query_string, view_parameters].compact.join('&')
        new_href += '?' + parameters unless parameters.blank?
        link.set_attribute 'href', new_href if new_href
      rescue URI::InvalidURIError => e
        Rails.logger.error "[Campaign] Translink Fix Anchors: Invalid URL error detected: '#{link}'"
        errors.add :email_html, I18n.t('campaigns.bad_uri', :url => link)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "[Campaign] Translink Fix Anchors: Active record error: #{e.message}"
        Rails.logger.error "[Campaign] Translink URL was '#{url}'"
        errors.add :email_html, e.message 
      end
    end
  end
  
  def fix_images!(email_content, email)  
    (email/"img").each do |link|
      url = link['src']
      next if url == '#'
      begin
        uri = URI.parse(url)
        next if uri.scheme
        new_url = [email_content.base_url || email_content.url, url].compress.join('/')
        link.set_attribute 'src', new_url
      rescue URI::InvalidURIError => e
        Rails.logger.error "[Campaign] Translink Fix Images: Invalid URL: '#{link}'"
        errors.add :email_html, I18n.t('campaigns.bad_uri', :url => link)
      end
    end
  end
  
  def add_tracker_link!(email_content, email)
    tracking_node = Nokogiri::XML::Node.new('img', email)
    tracking_node['src'] = [Trackster::Config.tracker_url, open_parameters].join('?')
    tracking_node['style'] = "display:none"
    body = email.css("body").first
    body.add_child(tracking_node)
  end
  
  def refers_to
    self
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
    params = "utac=#{Account.current_account.tracker}&utm_campaign=#{self.code}&utm_medium=#{self.medium}"
    params += "&utm_content=#{self.content}" unless self.content.blank?
    params += "&utm_source=#{self.source}" unless self.source.blank?
    params += "&utid=#{MAGIC_MARKER}" unless self.contact_code.blank?
    params
  end
  
  def view_parameters
    campaign_parameters + "&utcat=page&utact=view"
  end
  
  def open_parameters
    campaign_parameters + "&utcat=email&utact=open"
  end
  
  MAGIC_ENTITY = '!!ZXZX!!'
  def fix_entities(text)
    text.gsub('&',MAGIC_ENTITY)
  end
  
  def unfix_entities(text)
    text.gsub(MAGIC_ENTITY,'&')
  end
end
