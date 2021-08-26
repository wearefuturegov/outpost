class AddAdminManageOfstedAccessToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :admin_manage_ofsted_access, :boolean, default: false, null: false
  end
end
