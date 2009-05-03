class AddUrlToProperty < ActiveRecord::Migration
  def self.up
    add_column :properties, :url, :string
  end

  def self.down
    remove_column :properties, :url
  end
end
