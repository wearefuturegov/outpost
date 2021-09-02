class AddDirectoriesColumnToServices < ActiveRecord::Migration[6.0]
  def change
    add_column :services, :directories, :text, array: true, default: []
  end
end
