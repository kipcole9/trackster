class AdjustContactColumnSizes < ActiveRecord::Migration
  def self.up
    change_column :contacts, :salutation_template, :string, :size => 100
    change_column :contacts, :given_name, :string, :size => 100
    change_column :contacts, :family_name, :string, :size => 100
    change_column :contacts, :role, :string, :size => 100
    change_column :contacts, :photo_content_type, :string, :size => 50        
  end

  def self.down
  end
end
