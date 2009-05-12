class AddCountToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :count, :integer
  end

  def self.down
    remove_column :sessions, :count
  end
end
