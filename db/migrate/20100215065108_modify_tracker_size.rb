class ModifyTrackerSize < ActiveRecord::Migration
  def self.up
    change_column :accounts, :tracker, :string, :limit => 15
  end

  def self.down
  end
end
