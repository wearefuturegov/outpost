class MarkForDeletionOnUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :marked_for_deletion, :datetime
  end
end
