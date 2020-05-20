class AddOrderToTaxonomies < ActiveRecord::Migration[6.0]
  def change
    add_column :taxonomies, :sort_order, :integer
  end
end
