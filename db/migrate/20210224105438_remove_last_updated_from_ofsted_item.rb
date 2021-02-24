class RemoveLastUpdatedFromOfstedItem < ActiveRecord::Migration[6.0]
  def change
    remove_column :ofsted_items, :lastupdated, :datetime
  end
end
