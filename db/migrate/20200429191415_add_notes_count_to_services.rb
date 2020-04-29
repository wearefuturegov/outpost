class AddNotesCountToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :notes_count, :integer, default: 0, null: false
  end
end
