class ChangeOfstedItemReferenceNumberToString < ActiveRecord::Migration[6.0]
  def change
    change_column :ofsted_items, :reference_number, :string
  end
end
