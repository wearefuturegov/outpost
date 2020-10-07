class AddFlagToCustomFields < ActiveRecord::Migration[6.0]
  def change
    add_column :custom_fields, :public, :boolean
  end
end
