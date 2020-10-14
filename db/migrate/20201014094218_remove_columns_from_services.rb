class RemoveColumnsFromServices < ActiveRecord::Migration[6.0]
  def change
    remove_column :services, :bccn_member, :boolean
    remove_column :services, :pick_up_drop_off_service, :boolean
    remove_column :services, :current_vacancies, :boolean
  end
end
