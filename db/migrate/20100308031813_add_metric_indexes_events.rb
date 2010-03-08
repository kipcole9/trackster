class AddMetricIndexesEvents < ActiveRecord::Migration
  def self.up
    add_index :events, :url
    add_index :events, :label
  end

  def self.down
    remove_index :events, :url
    remove_index :events, :label
  end
end
