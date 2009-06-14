class Item < ActiveRecord::Base
  belongs_to                :opportunity
  validates_associated      :opportunity
  after_save                :update_opportunity_value
  
  protected
  
  # Update the opportunity value to be the sum of all its
  # Items
  def update_opportunity_value
    self.opportunity.reload_value_from_items
  end
end