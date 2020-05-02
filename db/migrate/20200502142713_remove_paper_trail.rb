class RemovePaperTrail < ActiveRecord::Migration[6.0]
  def change
    drop_table :versions
  end
end
