class AddTitlePrefixToProperties < ActiveRecord::Migration
  def self.up
    add_column :properties, :title_prefix, :string, :limit => 50
  end

  def self.down
    remove_column :properties, :title_prefix
  end
end
