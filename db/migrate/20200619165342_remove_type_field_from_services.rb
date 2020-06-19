class RemoveTypeFieldFromServices < ActiveRecord::Migration[6.0]
  def change
    remove_column :services, :type
  end
end
