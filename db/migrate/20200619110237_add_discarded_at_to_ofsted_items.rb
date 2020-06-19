class AddDiscardedAtToOfstedItems < ActiveRecord::Migration[6.0]
  def change
    add_column :ofsted_items, :discarded_at, :datetime
    add_index :ofsted_items, :discarded_at
  end
end
