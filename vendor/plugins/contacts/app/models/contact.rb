class Contact < ActiveRecord::Base
  unloadable
  include       Analytics::Model
  include       Contacts::VcardImporter
  
  validates_associated    :account
  validates_presence_of   :account_id
  
  default_scope :order => 'family_name ASC'
    
  acts_as_taggable_on :permissions, :categories, :tags
  before_save   :check_name_order
  
  # Analytics data
  has_many      :tracks,              :foreign_key => :contact_code, :primary_key => :contact_code
  
  # Contact relationships
  belongs_to    :account
  belongs_to    :team
  belongs_to    :created_by,          :class_name => "User", :foreign_key => :created_by
  belongs_to    :updated_by,          :class_name => "User", :foreign_key => :updated_by
  
  # Contact related-data
  has_one       :background
  has_many      :affiliates  
  has_many      :actions,             :as => :actionable, :class_name => "History", :order => "created_at DESC"
  has_many      :updates,             :as => :historical, :class_name => "History"
  has_many      :notes,               :as => :notable
  has_many      :websites,            :autosave => true, :validate => true, :dependent => :destroy
  has_many      :emails,              :autosave => true, :validate => true, :dependent => :destroy
  has_many      :instant_messengers,  :autosave => true, :validate => true, :dependent => :destroy
  has_many      :phones,              :autosave => true, :validate => true, :dependent => :destroy
  has_many      :addresses,           :autosave => true, :validate => true, :dependent => :destroy do
    # How to decide if an address exists?
    # Street address is almost useless since its format
    # varies widely.  We'll use city, region, country
    # and kind as the "close enough" test.
    def find_by_vcard(card_address)
      conditions = ["locality", "region", "country", "postalcode"].inject(Hash.new) do |conditions, address|
        address_part = card_address.send(address)
        conditions.merge!(address => address_part) unless address_part.blank?
        conditions
      end
      if conditions && !conditions.blank?
        conditions['country'] = Country.code(conditions['country']) if conditions['country'] 
        address = find(:first, :conditions => sanitize_sql_for_conditions(conditions))
      end
      address
    end
  end
  
  named_scope :for_user, lambda {|user|
    { :joins => {:team => :users}, :conditions => ["users.id = ?", user.id] } 
  }
  
  named_scope :search, lambda {|criteria|
    names = criteria.split(' ').map(&:strip)
    conditions = names.inject([]) do |conditions, name|
      conditions << "given_name LIKE '%#{quote_string(name)}%' OR family_name LIKE '%#{quote_string(name)}%' or name LIKE '%#{quote_string(name)}%'" unless name.blank?
    end
    { :conditions => conditions.join(' OR ') }
  } 
  
  has_attached_file :photo, :styles => { :thumbnail=> "200x200#", :small  => "150x150>", :avatar => "50x50#" },
                    :convert_options => { :all => "-unsharp 0.3x0.3+3+0" }
   
  accepts_nested_attributes_for :websites,            
                                :allow_destroy => true, 
                                :reject_if => proc { |attributes| attributes['url'].blank? }
  accepts_nested_attributes_for :emails,              
                                :allow_destroy => true, 
                                :reject_if => proc { |attributes| attributes['address'].blank? }
  accepts_nested_attributes_for :instant_messengers,  
                                :allow_destroy => true, 
                                :reject_if => proc { |attributes| attributes['name'].blank? }
  accepts_nested_attributes_for :phones,              
                                :allow_destroy => true, 
                                :reject_if => proc { |attributes| attributes['number'].blank? }
  accepts_nested_attributes_for :addresses,           
                                :allow_destroy => true, 
                                :reject_if => proc { |attributes| attributes.all? {|k, v| v.blank?} }

  # Used by History#record which decides who the parent object is.  By default it
  # will look for a relevant belongs_to, but sometimes defining it directly is
  # appropriate.
  def refers_to
    self
  end
  
protected
  def given_first?
    self.name_order == "gf"
  end
  
private
  def check_name_order
    self.name_order = "gf" if self.name_order.blank?
  end
  
  def self.quote_string(string)
    ActiveRecord::Base.connection.quote_string(string)
  end
  
  def must_have_name_or_code
    errors.add_to_base(I18n.t('contacts.need_name_or_code')) if given_name.blank? && family_name.blank? && contact_code.blank?
  end  

end
