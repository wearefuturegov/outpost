class AddStatusToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :temporarily_closed, :boolean
  end
end
