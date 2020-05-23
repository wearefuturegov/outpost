class CreateRegularSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :regular_schedules do |t|
      t.references :service, null: false, foreign_key: true
      t.time :opens_at
      t.time :closes_at
      t.integer :weekday

      t.timestamps
    end
  end
end
