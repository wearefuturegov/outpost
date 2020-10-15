class DropSnapshotsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :snapshots
  end
end
