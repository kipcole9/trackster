class ReduceSizeOfCountryColumn < ActiveRecord::Migration
  def self.up
    change_column :sessions, :country, :string, :limit => 2
  end

  def self.down
    change_column :sessions, :country, :string, :limit => 30
  end
end
