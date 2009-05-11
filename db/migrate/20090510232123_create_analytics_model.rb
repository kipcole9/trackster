class CreateAnalyticsModel < ActiveRecord::Migration
  def self.up
    drop_table :tracks
  end

  def self.down

  end
end
