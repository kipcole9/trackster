class AddEventsToTrack < ActiveRecord::Migration
  def self.up
    add_column :tracks, :category, :string
    add_column :tracks, :action, :string
    add_column :tracks, :label, :string
    add_column :tracks, :value, :float
  end

  def self.down
    remove_column :tracks, :value
    remove_column :tracks, :label
    remove_column :tracks, :action
    remove_column :tracks, :category
  end
end
