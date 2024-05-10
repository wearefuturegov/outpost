class AddCustomFieldsCountToCustomFieldSections < ActiveRecord::Migration[6.0]
  def change
    add_column :custom_field_sections, :custom_fields_count, :integer
  end
end
