class AddCascadeDeleteToRegularSchedules < ActiveRecord::Migration[6.0]
  def change
    # Remove the existing foreign key constraint
    remove_foreign_key :regular_schedules, :service_at_locations

    # Add the new foreign key constraint with ON DELETE CASCADE
    add_foreign_key :regular_schedules, :service_at_locations, on_delete: :cascade
  end
end
