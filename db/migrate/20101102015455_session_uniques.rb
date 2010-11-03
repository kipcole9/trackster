class SessionUniques < ActiveRecord::Migration
  def self.up
    add_column :sessions, :first_impression, :boolean
    add_column :sessions, :first_click, :boolean
    
    change_column :events, :entry_page, :boolean, :default => nil
    change_column :events, :exit_page, :boolean, :default => nil
    
    execute 'update events set entry_page = NULL where entry_page = 0'
    execute 'update events set exit_page = NULL where exit_page = 0'
  end

  def self.down
    remove_column :sessions, :first_impression
    remove_column :sessions, :first_click
    
    change_column :events, :entry_page, :boolean, :default => 1
    change_column :events, :exit_page, :boolean, :default => 1
    
    execute 'update events set entry_page = 0 where entry_page IS NULL'
    execute 'update events set exit_page = 0 where exit_page IS NULL'
  end
end
