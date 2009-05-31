class AddDurationToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :duration, :integer
  end

  def self.down
    remove_column :events, :duration
  end
end
