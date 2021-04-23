class AddForeignKeyToContacts < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :contacts, :services, column: :service_id
  end
end
