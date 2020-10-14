class CreateCustomFieldSections < ActiveRecord::Migration[6.0]
  def change
    create_table :custom_field_sections do |t|
      t.string :name
      t.string :instructions

      t.timestamps
    end
  end
end
