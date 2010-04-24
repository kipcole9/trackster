class RenameDayToDayOfMonth < ActiveRecord::Migration
  def self.up
    rename_column :sessions, :day, :day_of_month
  end

  def self.down
  end
end
