class AddAPIVisibilityToCustomField < ActiveRecord::Migration[6.0]
  def change
    add_column :custom_fields, :api_public, :boolean
  end
end
