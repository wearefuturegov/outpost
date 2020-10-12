class AddColumnsToVersions < ActiveRecord::Migration[6.0]
  def change
    remove_column :versions, :object, :text
    remove_column :versions, :object_changes, :text

    add_column :versions, :object, :json
    add_column :versions, :object_changes, :json
  end
end
