class AddPostalPreferenceToLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :locations, :preferred_for_post, :boolean
  end
end
