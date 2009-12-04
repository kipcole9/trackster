class AddTrackerToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :tracker, :string, :limit => 10
    add_index :accounts, :tracker, :unique => true
  end

  def self.down
    remove_column :accounts, :tracker
  end
end
