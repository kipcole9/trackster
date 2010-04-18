class ContentVariant < ActiveRecord::Base
  set_table_name  'content_variants'
  belongs_to      :content
  has_many        :language_versions, :autosave => true, :dependent => :destroy
  
  validates_presence_of     :name
  validates_uniqueness_of   :name,            :scope => :content_id
  validates_length_of       :name,            :within => 3..50
  
end
