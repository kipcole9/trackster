class AddAccountToHistories < ActiveRecord::Migration
  def self.up
    add_column :histories, :account_id, :integer
  end

  def self.down
    remove_column :histories, :account_id
  end
end
