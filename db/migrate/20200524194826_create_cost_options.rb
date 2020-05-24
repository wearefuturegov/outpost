class CreateCostOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :cost_options do |t|
      t.references :service, null: false, foreign_key: true
      t.string :option
      t.float :amount

      t.timestamps
    end
  end
end
