class RemoveUniqueContactCodeIndex < ActiveRecord::Migration
  def self.up
    remove_index :contacts , [:account_id, :contact_code]
  end

  def self.down
  end
end
