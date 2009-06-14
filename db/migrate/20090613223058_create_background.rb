class CreateBackground < ActiveRecord::Migration
  def self.up
    create_table :backgrounds do |t|
      t.belongs_to      :contact 
      t.text            :description
    end
  end

  def self.down
  end
end
