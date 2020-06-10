class AddAdminOfstedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admin_ofsted, :boolean
  end
end
