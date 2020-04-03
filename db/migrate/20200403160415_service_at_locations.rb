class ServiceAtLocations < ActiveRecord::Migration[6.0]
  def change
    create_table :service_at_locations do |t|
      t.integer :service_id, null: false
      t.integer :location_id, null: false
    end
  end
end
