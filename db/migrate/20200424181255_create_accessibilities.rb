class CreateAccessibilities < ActiveRecord::Migration[6.0]
  def change
    create_table :accessibilities do |t|
      t.string :name

      t.timestamps
    end

    create_join_table(:locations, :accessibilities)
  end
end
