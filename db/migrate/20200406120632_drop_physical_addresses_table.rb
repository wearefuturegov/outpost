class DropPhysicalAddressesTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :physical_addresses
  end
end
