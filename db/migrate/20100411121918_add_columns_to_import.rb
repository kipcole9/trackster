class AddColumnsToImport < ActiveRecord::Migration
  def self.up
    add_column :imports, :messages, :text
    add_column :imports, :started_at, :datetime
    add_column :imports, :ended_at, :datetime
    add_column :imports, :records, :integer
  end

  def self.down
    remove_column :imports, :records
    remove_column :imports, :ended_at
    remove_column :imports, :started_at
    remove_column :imports, :messages
  end
end
