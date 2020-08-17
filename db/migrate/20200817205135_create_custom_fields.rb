class CreateCustomFields < ActiveRecord::Migration[6.0]
  def change
    create_table :custom_fields do |t|
      t.string :key
      t.string :field_type

      t.timestamps
    end
  end
end
