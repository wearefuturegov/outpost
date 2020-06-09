class AddMaskFieldToLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :mask_exact_address, :boolean
  end
end
