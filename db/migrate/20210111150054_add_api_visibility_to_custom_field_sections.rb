class AddAPIVisibilityToCustomFieldSections < ActiveRecord::Migration[6.0]
  def change
    remove_column :custom_fields, :api_public
    add_column :custom_field_sections, :api_public, :boolean
  end
end
