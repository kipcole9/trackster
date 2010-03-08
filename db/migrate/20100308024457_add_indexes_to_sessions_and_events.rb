class AddIndexesToSessionsAndEvents < ActiveRecord::Migration
  def self.up
    add_index :sessions, :started_at
    add_index :sessions, :date
    add_index :sessions, :day
    add_index :sessions, :month
    add_index :sessions, :day_of_week
    add_index :sessions, :year
    add_index :sessions, :hour
    add_index :events, :tracked_at
  end

  def self.down
    drop_index :sessions, :started_at
    drop_index :sessions, :date
    drop_index :sessions, :day
    drop_index :sessions, :month
    drop_index :sessions, :day_of_week
    drop_index :sessions, :year
    drop_index :sessions, :hour
    drop_index :events, :tracked_at
  end
end
