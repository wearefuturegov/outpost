class AddOldExternalIdToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :old_external_id, :string
  end
end
