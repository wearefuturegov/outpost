class AddMoreScoutDataToDirectories < ActiveRecord::Migration[6.0]
  def change
    add_column :directories, :scout_build_hook, :string
    add_column :directories, :scout_url, :string
    add_column :directories, :is_public, :boolean, default: true
  end
end