class RemoveCertificateConditionFromOfstedItems < ActiveRecord::Migration[6.0]
  def change
    remove_column :ofsted_items, :certificate_condition, :string
  end
end
