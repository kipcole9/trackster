class ChangeSalutationToSalutationTemplateForContacts < ActiveRecord::Migration
  def self.up
    rename_column :contacts, :salutation, :salutation_template
  end

  def self.down
    rename_column :contacts, :salutation_template, :salutation
  end
end
