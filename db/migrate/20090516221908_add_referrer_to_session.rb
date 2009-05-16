class AddReferrerToSession < ActiveRecord::Migration
  def self.up
    add_column :sessions, :referrer, :string
    add_column :sessions, :referrer_host, :string, :limit => 100
    add_column :sessions, :search_terms, :string
    execute 'update sessions join events on sessions.id = events.session_id ' +
            'set sessions.referrer = events.referrer, sessions.search_terms = events.search_terms ' +
            'where entry_page = 1 and events.referrer is not null'
    rename_column :events, :search_terms, :internal_search_terms
    remove_column :events, :referrer
    remove_column :events, :referrer_host
  end

  def self.down
    remove_column :sessions, :search_terms
    remove_column :sessions, :referrer
    remove_column :sessions, :referrer_host
  end
end
