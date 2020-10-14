class MovePublicOntoCustomFieldSections < ActiveRecord::Migration[6.0]
  def change
    remove_column :custom_fields, :public, :boolean
    add_column :custom_field_sections, :public, :boolean

    rename_column :custom_field_sections, :instructions, :hint
  end
end
