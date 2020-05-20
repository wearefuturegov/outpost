class AddVisibleToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :visible, :boolean
  end
end
