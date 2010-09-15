class Content < ActiveRecord::Base
  belongs_to        :account
  has_many          :variants, :class_name => 'ContentVariant', :autosave => true, :dependent => :destroy
  after_save        :update_version
  
  validates_presence_of     :name
  validates_uniqueness_of   :name,            :scope => :account_id
  validates_length_of       :name,            :within => 3..100  
  validates_url_format_of   :url,             :allow_nil => true

  named_scope :search, lambda {|criteria|
    search = "%#{criteria}%"
    {:conditions => ['name like ? or description like ?', search, search ]}
  }
  
  def url
    variants.first.language_versions.first.url rescue @url
  end
  
  def url=(address)
    return if address.blank?
    @url = URI.split(address)[0] ? address : "http://#{address}"
    @url = @url.without_slash
    @file = open(address) do |f|
      @content_type   = f.content_type
      @language       = f.instance_variable_get('@meta')['content-language']
      @file_contents  = f.read
    end 
  rescue Errno::ENOENT => e
    errors.add(:url, e)
  rescue URI::InvalidURIError => e
    errors.add(:url, e)
  rescue SocketError => e
    errors.add(:url, e)
  rescue OpenURI::HTTPError => e
    errors.add(:url, e)  
  end
  
  def base_url=(base)
    @base_url = base.without_slash unless base.blank?
  end
  
  def base_url
    variants.first.language_versions.first.base_url rescue @base_url   
  end
  
  def content
    variants.first.language_versions.first.content rescue @file_contents
  end
  
  def content_file=(file)
    if file.respond_to?(:read)
      @file_contents = file.read
      @original_name = file.try(:original_filename)
      @content_type  = Mime::Type.lookup_by_extension(File.extname(@original_name)[1..-1]).to_s
    else
      @file_contents = file unless file.blank?
    end
  end
  
private
  def update_version
    variant = self.variants.find(:first) || self.variants.create(:name => "Singleton Variant")
    version = variant.language_versions.find(:first) || variant.language_versions.build
    version.url                 = @url if @url
    version.content             = @file_contents if @file_contents
    version.original_file_name  = @original_name if @original_name
    version.mime_type           = @content_type  if @content_type
    version.mime_type           = 'text/plain'   if version.mime_type.blank?
    version.language            = @language      if @language
    version.base_url            = @base_url      if @base_url
    version.base_url            = base_url_from_content(version.content) if @base_url.blank?
    version.save
  end
  
  def base_url_from_content(content)
    html = ::Nokogiri::HTML(content)
    (html/"base").each do |link|
      return link['href'] if link['href']
    end
    nil
  end

end
