class RenameRedirectColumns < ActiveRecord::Migration
  def self.up
    rename_column :redirects, :event_category, :category
    rename_column :redirects, :event_action, :action
    rename_column :redirects, :event_label, :label
    rename_column :redirects, :event_value, :value
  end

  def self.down
  end
end
