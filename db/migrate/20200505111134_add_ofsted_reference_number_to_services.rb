class AddOfstedReferenceNumberToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :ofsted_reference_number, :string
  end
end
