class AddPreviousSessionAtToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :previous_visit_at, :datetime
  end

  def self.down
    remove_column :sessions, :previous_visit_at
  end
end
