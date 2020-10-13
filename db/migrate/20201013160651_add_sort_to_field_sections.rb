class AddSortToFieldSections < ActiveRecord::Migration[6.0]
  def change
    add_column :custom_field_sections, :sort_order, :integer
  end
end
