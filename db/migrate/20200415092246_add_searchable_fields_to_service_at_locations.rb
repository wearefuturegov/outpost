class AddSearchableFieldsToServiceAtLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :service_at_locations, :service_name, :string
    add_column :service_at_locations, :service_description, :text
    add_column :service_at_locations, :service_url, :string
    add_column :service_at_locations, :service_email, :string
    add_column :service_at_locations, :postcode, :string
    add_column :service_at_locations, :latitude, :decimal, { precision: 10, scale: 6 }
    add_column :service_at_locations, :longitude, :decimal, { precision: 10, scale: 6 }
  end
end
