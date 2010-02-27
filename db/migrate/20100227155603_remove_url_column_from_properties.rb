class RemoveUrlColumnFromProperties < ActiveRecord::Migration
  def self.up
    remove_column :properties, :url
  end

  def self.down
    add_column :properties, :url, :string
  end
end
