class CreatePlanningAreas < ActiveRecord::Migration[6.0]
  def change
    create_table :planning_areas do |t|
      t.string :postcode
      t.string :primary_planning_area
    end
  end
end
