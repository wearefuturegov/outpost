class RemoveOfstedReferenceNumberAndOldOfstedExternalIdFromServices < ActiveRecord::Migration[6.0]
  def change

    remove_column :services, :ofsted_reference_number, :string
    remove_column :services, :old_ofsted_external_id, :string
  end
end
