class AddReferrerHostToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :referrer_host, :string, :limit => 100
  end

  def self.down
    remove_column :events, :referrer_host
  end
end
