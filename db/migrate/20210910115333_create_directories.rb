class CreateDirectories < ActiveRecord::Migration[6.0]
  def change
    create_table :directories do |t|
      t.string :name
      t.string :label

      t.timestamps
    end

    create_join_table(:services, :directories)
  end
end
