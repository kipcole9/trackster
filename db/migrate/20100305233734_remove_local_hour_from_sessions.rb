class RemoveLocalHourFromSessions < ActiveRecord::Migration
  def self.up
    remove_column :sessions, :local_hour
  end

  def self.down
    add_column :sessions, :local_hour, :integer
  end
end
