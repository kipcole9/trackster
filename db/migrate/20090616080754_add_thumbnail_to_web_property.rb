class AddThumbnailToWebProperty < ActiveRecord::Migration
  def self.up
    add_column :properties, :thumb_file_name, :string, :limit => 100
    add_column :properties, :thumb_content_type, :string, :limit => 50
    add_column :properties, :thumb_file_size, :integer
  end

  def self.down
    remove_column :properties, :thumb_file_size
    remove_column :properties, :thumb_content_type
    remove_column :properties, :thumb_file_name
  end
end
