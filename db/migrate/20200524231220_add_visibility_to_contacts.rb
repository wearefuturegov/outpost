class AddVisibilityToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :visible, :boolean
  end
end
