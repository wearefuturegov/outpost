class RenameEditsToSnapshots < ActiveRecord::Migration[6.0]
  def change
    rename_table :edits, :snapshots
  end
end
