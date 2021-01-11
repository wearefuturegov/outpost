class AddTypeToCostOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :cost_options, :type, :string
  end
end
