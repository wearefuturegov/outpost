class MoveEmailsToContacts < ActiveRecord::Migration[6.0]
  def change
    remove_column :services, :email
    add_column :contacts, :email, :string
  end
end
