class AddTrafficeSourceToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :traffic_source, :string, :limit => 10
    add_column :events, :search_terms, :string
  end

  def self.down
    remove_column :events, :traffic_source
    remove_column :events, :search_terms
  end
end
