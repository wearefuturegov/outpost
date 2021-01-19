class RemoveLinkedRegistrationFromOfstedItems < ActiveRecord::Migration[6.0]
  def change

    remove_column :ofsted_items, :linked_registration, :string
  end
end
