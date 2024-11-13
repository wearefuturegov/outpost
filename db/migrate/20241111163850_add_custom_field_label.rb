class AddCustomFieldLabel < ActiveRecord::Migration[6.0]
  def change
    # Add new label column
    add_column :custom_fields, :label, :string

    # Copy data from key to label (only on up migration)
    reversible do |dir|
      dir.up do
        CustomField.reset_column_information
        CustomField.update_all('label = key')
      end
    end
  end
end
