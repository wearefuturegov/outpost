class AddOldOpenObjectsExternalIdToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :old_open_objects_external_id, :string
  end
end
