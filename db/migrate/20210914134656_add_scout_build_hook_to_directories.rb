class AddScoutBuildHookToDirectories < ActiveRecord::Migration[6.0]
  def change
    add_column :directories, :scout_build_hook, :string
  end
end
