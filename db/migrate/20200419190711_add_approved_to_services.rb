class AddApprovedToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :approved, :boolean, default: true
  end
end
