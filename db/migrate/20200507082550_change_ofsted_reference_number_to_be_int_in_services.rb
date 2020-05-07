class ChangeOfstedReferenceNumberToBeIntInServices < ActiveRecord::Migration[6.0]
  def change
    change_column :services, :ofsted_reference_number, 'integer USING CAST(ofsted_reference_number AS integer)'
  end
end
