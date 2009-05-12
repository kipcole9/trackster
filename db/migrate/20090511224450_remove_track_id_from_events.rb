class RemoveTrackIdFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :track_id
  end

  def self.down
  end
end
