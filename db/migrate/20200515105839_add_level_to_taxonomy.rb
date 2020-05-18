class AddLevelToTaxonomy < ActiveRecord::Migration[6.0]
  def change
    add_column :taxonomies, :level, :integer
  end
end
