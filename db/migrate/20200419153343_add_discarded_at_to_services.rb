class AddDiscardedAtToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :discarded_at, :datetime
    add_index :services, :discarded_at
  end
end
