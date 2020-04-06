class AddAddressFieldsToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :address_1, :string
    add_column :locations, :city, :string
    add_column :locations, :state_province, :string
    add_column :locations, :postal_code, :string
    add_column :locations, :country, :string
  end
end
