class Variant < ActiveRecord::Base
  set_table_name  'content_variants'
  belongs_to      :content
  has_many        :language_versions, :autosave => true
  
end
