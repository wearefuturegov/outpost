class AddCounterCachesForOrganisation < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :users_count, :integer, default: 0, null: false
    add_column :organisations, :services_count, :integer, default: 0, null: false
  end
end
