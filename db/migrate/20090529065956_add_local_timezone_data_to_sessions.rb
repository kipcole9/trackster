class AddLocalTimezoneDataToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :local_hour, :integer, :limit => 2
    add_column :sessions, :lon_local_time, :boolean, :default => false
  end

  def self.down
    drop_column :sessions, :local_hour
    drop_column :sessions, :lon_local_time
  end
end
