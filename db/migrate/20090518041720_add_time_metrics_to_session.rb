class AddTimeMetricsToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :date, :date
    add_column :sessions, :day, :integer
    add_column :sessions, :year, :integer
    add_column :sessions, :month, :integer
    add_column :sessions, :hour, :integer
  end

  def self.down
    remove_column :sessions, :hour
    remove_column :sessions, :month
    remove_column :sessions, :year
    remove_column :sessions, :day
    remove_column :sessions, :date
  end
end
