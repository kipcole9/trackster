class CreateImports < ActiveRecord::Migration
  def self.up
    create_table :imports do |t|
      t.belongs_to      :account
      t.string          :description
      t.integer         :created_by
      t.string          :original_file
      t.timestamps
    end
  end

  def self.down
    drop_table :imports
  end
end
