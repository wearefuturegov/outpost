class AddAncestryToTaxonomies < ActiveRecord::Migration[6.0]
  def change
    add_column :taxonomies, :ancestry, :string
    add_index :taxonomies, :ancestry
  end
end
