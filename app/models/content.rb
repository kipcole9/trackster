class Content < ActiveRecord::Base
  belongs_to        :account
  has_many          :variants, :autosave => true
  
  validates_presence_of     :name
  validates_uniqueness_of   :name,            :scope => :account_id
  validates_length_of       :name,            :within => 3..50
  
  def url
    
  end
  
  def url=(addr)
    
  end
  
  def content_file
    
  end
  
  def content_file=(file)
    
  end

end
