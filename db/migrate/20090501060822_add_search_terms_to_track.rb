class AddSearchTermsToTrack < ActiveRecord::Migration
  def self.up
    add_column :tracks, :referrer_host, :string, :limit => 100
    add_column :tracks, :search_terms, :string
    add_column :tracks, :traffic_source, :string, :limit => 10
  end

  def self.down
    remove_column :tracks, :traffic_source
    remove_column :tracks, :search_terms
    remove_column :tracks, :referrer_host
  end
end
