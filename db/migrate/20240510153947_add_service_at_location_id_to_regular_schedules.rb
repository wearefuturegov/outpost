class AddServiceAtLocationIdToRegularSchedules < ActiveRecord::Migration[6.0]
  def change
    add_reference :regular_schedules, :service_at_location, null: true, foreign_key: true
  end
end
