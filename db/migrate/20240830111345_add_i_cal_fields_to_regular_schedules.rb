class AddICalFieldsToRegularSchedules < ActiveRecord::Migration[6.0]
  def change
    add_column :regular_schedules, :dtstart, :date
    add_column :regular_schedules, :freq, :string
    add_column :regular_schedules, :interval, :integer
    add_column :regular_schedules, :byday, :string
    add_column :regular_schedules, :bymonthday, :string
  end
end
