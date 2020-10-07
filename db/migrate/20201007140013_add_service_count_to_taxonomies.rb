class AddServiceCountToTaxonomies < ActiveRecord::Migration[6.0]
  def change
    add_column :taxonomies, :services_count, :integer
  end
end
