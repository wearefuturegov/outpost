class ClearCacheFieldsOffServiceAtLocation < ActiveRecord::Migration[6.0]
  def change
    remove_column :service_at_locations, :service_name
    remove_column :service_at_locations, :service_description
    remove_column :service_at_locations, :service_url
    remove_column :service_at_locations, :service_email
    remove_column :service_at_locations, :postcode
    remove_column :service_at_locations, :latitude
    remove_column :service_at_locations, :longitude
    remove_column :service_at_locations, :discarded_at
  end
end
