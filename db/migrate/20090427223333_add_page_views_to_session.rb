class AddPageViewsToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :page_views, :integer
  end

  def self.down
    remove_column :sessions, :page_views
  end
end
