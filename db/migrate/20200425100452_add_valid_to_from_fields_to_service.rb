class AddValidToFromFieldsToService < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :visible_from, :date
    add_column :services, :visible_to, :date
  end
end
