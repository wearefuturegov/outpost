class AddMarkedForDeletionToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :marked_for_deletion, :datetime
  end
end
