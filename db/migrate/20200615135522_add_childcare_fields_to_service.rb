class AddChildcareFieldsToService < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :bccn_membership_number, :string
    add_column :services, :current_vacancies, :boolean
    add_column :services, :pick_up_drop_off_service, :boolean
  end
end
