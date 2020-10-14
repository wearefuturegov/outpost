class AddForeignKeyToCustomFields < ActiveRecord::Migration[6.0]
  def change
    add_reference :custom_fields, :custom_field_section, null: false, foreign_key: true
  end
end
