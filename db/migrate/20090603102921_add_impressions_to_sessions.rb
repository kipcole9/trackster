class AddImpressionsToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :impressions, :integer
  end

  def self.down
    remove_column :sessions, :impressions
  end
end
