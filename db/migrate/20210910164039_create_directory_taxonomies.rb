class CreateDirectoryTaxonomies < ActiveRecord::Migration[6.0]
  def change
    create_join_table(:taxonomies, :directories)
  end
end
