class AddTypeToService < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :type, :string
  end
end
