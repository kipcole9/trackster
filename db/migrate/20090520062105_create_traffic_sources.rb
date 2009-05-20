class CreateTrafficSources < ActiveRecord::Migration
  def self.up
    create_table :traffic_sources do |t|
      t.belongs_to        :account
      t.string            :host
      t.string            :source_type
      t.timestamps
    end
  end

  def self.down
    drop_table :traffic_sources
  end
end
