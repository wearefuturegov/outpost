class AddLockedToTaxonomies < ActiveRecord::Migration[6.0]
  def change
    add_column :taxonomies, :locked, :boolean
  end
end
