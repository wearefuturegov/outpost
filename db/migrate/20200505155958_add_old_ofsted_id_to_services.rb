class AddOldOfstedIdToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :old_ofsted_external_id, :string
  end
end
