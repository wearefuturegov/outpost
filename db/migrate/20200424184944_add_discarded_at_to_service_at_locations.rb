class AddDiscardedAtToServiceAtLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :service_at_locations, :discarded_at, :datetime
    add_index :service_at_locations, :discarded_at
  end
end
