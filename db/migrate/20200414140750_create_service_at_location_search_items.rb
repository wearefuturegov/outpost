class CreateServiceAtLocationSearchItems < ActiveRecord::Migration[6.0]
  def change
    create_table :service_at_location_search_items do |t|
      t.integer :service_id
      t.string :service_name
      t.text :service_description
      t.string :service_url
      t.integer :location_id
      t.string :location_postal_code
      t.decimal :location_latitude, { precision: 10, scale: 6 }
      t.decimal :location_longitude, { precision: 10, scale: 6 }
    end
  end
end
