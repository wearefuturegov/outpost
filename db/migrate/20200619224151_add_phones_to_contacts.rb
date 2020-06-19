class AddPhonesToContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :contacts, :phone, :string
    drop_table :phones
  end
end
