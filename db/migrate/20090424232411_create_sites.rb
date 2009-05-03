class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :properties do |t|
      t.belongs_to      :account
      t.string          :name
      t.text            :description
      t.string          :tracker
      t.timestamps
    end
  end

  def self.down
    drop_table :properties
  end
end
