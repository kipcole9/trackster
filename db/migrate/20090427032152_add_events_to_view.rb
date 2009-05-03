class AddEventsToView < ActiveRecord::Migration
  def self.up
    add_column :views, :event_category, :string
    add_column :views, :event_action, :string
    add_column :views, :event_label, :string
    add_column :views, :event_value, :float
    rename_column :views, :viewed_at, :tracked_at
  end

  def self.down
    remove_column :views, :event_value
    remove_column :views, :event_label
    remove_column :views, :event_action
    remove_column :views, :event_category
    rename_column :views, :tracked_at, :viewed_at
  end
end
