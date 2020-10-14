class AddOptionsToCustomFields < ActiveRecord::Migration[6.0]
  def change
    add_column :custom_fields, :options, :string
  end
end
