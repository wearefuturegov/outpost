class RenameTypeColumnOnCostOptions < ActiveRecord::Migration[6.0]
  def change
    rename_column :cost_options, :type, :cost_type
  end
end
