class AddMobileDeviceToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :device, :string, :limit => 50
    add_column :sessions, :device_vendor, :string, :limit => 50
  end

  def self.down
    remove_column :sessions, :device
    remove_column :sessions, :device_vendor
  end
end
