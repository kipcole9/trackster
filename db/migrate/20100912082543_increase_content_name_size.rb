class IncreaseContentNameSize < ActiveRecord::Migration
  def self.up
    change_column :contents, :name, :string, :limit => 100
  end

  def self.down
    change_column :contents, :name, :string, :limit => 50
  end
end
