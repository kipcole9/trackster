class CreateContactCodeIndex < ActiveRecord::Migration
  def self.up
    add_index :contacts, [:account_id, :contact_code]
  end

  def self.down
  end
end
