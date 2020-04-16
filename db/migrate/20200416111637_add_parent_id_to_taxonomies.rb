class AddParentIdToTaxonomies < ActiveRecord::Migration[6.0]
  def change
    add_reference :taxonomies, :parent, index: true
  end
end
