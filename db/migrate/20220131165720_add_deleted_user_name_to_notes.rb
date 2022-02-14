class AddDeletedUserNameToNotes < ActiveRecord::Migration[6.0]
  def up
    add_column :notes, :deleted_user_name, :string
    change_column_null :notes, :user_id, true
  end

  def down
    remove_column :notes, :deleted_user_name

    # Get rid of any notes that no longer have an associated user
    Note.where(user_id: nil).find_each do |note|
      note.destroy!
    end

    change_column_null :notes, :user_id, false
  end
end
