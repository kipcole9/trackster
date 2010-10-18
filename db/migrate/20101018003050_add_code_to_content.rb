class AddCodeToContent < ActiveRecord::Migration
  def self.up
    add_column :contents, :code, :string, :limit => 10
    add_index :contents, :code, :unique => true
  end

  def self.down
    remove_column :contents, :code
  end
end
