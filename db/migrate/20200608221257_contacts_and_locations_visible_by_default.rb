class ContactsAndLocationsVisibleByDefault < ActiveRecord::Migration[6.0]
  def change

    change_column :contacts, :visible, :boolean, default: true
    change_column :locations, :visible, :boolean, default: true
  end
end
