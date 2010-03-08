class AddMetricIndexesSessions < ActiveRecord::Migration
  def self.up
    add_index :sessions, :country
    add_index :sessions, :language
    add_index :sessions, :browser
    add_index :sessions, :device
    add_index :sessions, :os_name
    add_index :sessions, :os_version
    add_index :sessions, :search_terms
    add_index :sessions, :referrer_host
  end

  def self.down
    remove_index :sessions, :country
    remove_index :sessions, :language
    remove_index :sessions, :browser
    remove_index :sessions, :device
    remove_index :sessions, :os_name
    remove_index :sessions, :os_version
    remove_index :sessions, :search_terms
    remove_index :sessions, :referrer_host    
  end
end
