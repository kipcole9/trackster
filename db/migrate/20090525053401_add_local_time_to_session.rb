class AddLocalTimeToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :day_of_week, :integer, :limit => 1
    add_column :sessions, :timezone, :integer, :limit => 3
  end

  def self.down
    remove_column :sessions, :day_of_week
    remove_column :sessions, :timezone
  end
end
