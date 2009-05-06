class RemoveDurationFromEvent < ActiveRecord::Migration
  def self.up
    remove_column :events, :duration
  end

  def self.down
    add_column :events, :duration, :integer
  end
end
