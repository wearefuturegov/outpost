class AddAdminUsersToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admin_users, :boolean
  end
end
