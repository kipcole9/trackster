class CreatePropertyUsers < ActiveRecord::Migration
  def self.up
    create_table :property_users do |t|
      t.belongs_to    :user
      t.belongs_to    :property
      t.timestamps
    end
  end

  def self.down
    drop_table :property_users
  end
end
