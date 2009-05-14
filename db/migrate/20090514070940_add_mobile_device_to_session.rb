class AddMobileDeviceToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :mobile_device, :boolean
  end

  def self.down
    remove_column :sessions, :mobile_device
  end
end
