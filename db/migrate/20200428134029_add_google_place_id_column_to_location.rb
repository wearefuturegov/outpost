class AddGooglePlaceIdColumnToLocation < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :google_place_id, :string
  end
end
