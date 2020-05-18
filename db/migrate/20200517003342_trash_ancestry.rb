class TrashAncestry < ActiveRecord::Migration[6.0]
  def change
    remove_column :taxonomies, :ancestry
  end
end
