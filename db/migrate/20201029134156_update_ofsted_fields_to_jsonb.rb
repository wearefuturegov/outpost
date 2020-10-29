class UpdateOfstedFieldsToJsonb < ActiveRecord::Migration[6.0]
  def change
    change_column :ofsted_items, :registration_status_history, :jsonb, using: 'registration_status_history::jsonb'
    change_column :ofsted_items, :child_services_register, :jsonb, using: 'child_services_register::jsonb'
  end
end
