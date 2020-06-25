class AddOpenObjectsExternalIdToOfstedItems < ActiveRecord::Migration[6.0]
  def change
    add_column :ofsted_items, :open_objects_external_id, :string
  end
end
