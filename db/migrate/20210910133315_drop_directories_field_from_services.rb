

class DropDirectoriesFieldFromServices < ActiveRecord::Migration[6.0]
  def change
    remove_column :services, :directories
  end
end
