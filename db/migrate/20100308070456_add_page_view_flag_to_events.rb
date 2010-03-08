class AddPageViewFlagToEvents < ActiveRecord::Migration
  def self.up
    # ALthough events are arbitrary, page views are most common
    # so we want to make retrieving them faster
    add_column :events, :page_view, :boolean
    add_index :events, :page_view
  end

  def self.down
    remove_column :events, :page_view
  end
end
