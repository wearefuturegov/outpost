class AddExtraTextFieldForDirectories < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :directories_as_text, :text
  end
end
