class CreateSearchEngines < ActiveRecord::Migration
  def self.up
    create_table :search_engines do |t|
      t.string          :host
      t.string          :query_param, :limit => 10
      t.string          :country, :limit => 10
      t.timestamps
    end
    add_index :search_engines, :host, :unique => true
  end

  def self.down
    drop_table :search_engines
  end
end
