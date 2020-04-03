class CreatePhysicalAddresses < ActiveRecord::Migration[6.0]
  def change
    create_table :physical_addresses do |t|
      t.belongs_to :location
      t.string :address_1
      t.string :city
      t.string :state_province
      t.string :postal_code
      t.string :country
    end
  end
end
