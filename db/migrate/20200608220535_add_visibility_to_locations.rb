class AddVisibilityToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :visible, :boolean
  end
end
