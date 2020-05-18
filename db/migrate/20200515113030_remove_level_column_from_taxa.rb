class RemoveLevelColumnFromTaxa < ActiveRecord::Migration[6.0]
  def change
    remove_column :taxonomies, :level
  end
end
