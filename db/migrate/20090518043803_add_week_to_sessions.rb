class AddWeekToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :week, :integer
  end

  def self.down
    remove_column :sessions, :week
  end
end
