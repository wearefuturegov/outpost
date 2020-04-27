class AddChangeColumnToEdits < ActiveRecord::Migration[6.0]
  def change
    add_column :edits, :object_changes, :json
  end
end
