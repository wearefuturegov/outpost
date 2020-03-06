class AddOldExternalIdToOrganisations < ActiveRecord::Migration[6.0]
  def change
    add_column :organisations, :old_external_id, :string
  end
end
