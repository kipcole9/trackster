class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.belongs_to        :account
      t.string            :name,     :limit => 100
      t.text              :description
      t.string            :purpose,  :limit => 50
      
      # For audit
      t.integer           :created_by
      t.integer           :updated_by
      t.timestamps
    end
    
    create_table :content_variants do |t|
      t.belongs_to        :content
      t.string            :name ,   :limit => 100
      t.text              :description
      
      # For audit
      t.integer           :created_by
      t.integer           :updated_by
      t.timestamps
    end
    
    create_table :language_versions do |t|
      t.belongs_to        :content_variant
      t.string            :language,  :limit => 50
      
      # For referenced content
      t.string            :url
      
      # For uploaded content
      t.text              :content
      t.string            :original_file_name
      t.string            :mime_type, :limit => 50
      
      # For audit
      t.integer           :created_by
      t.integer           :updated_by
      t.timestamps
    end
  end

  def self.down
    drop_table :contents
    drop_table :content_variants
    drop_table :language_versions
  end
end
