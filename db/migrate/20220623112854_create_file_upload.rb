class CreateFileUpload < ActiveRecord::Migration[6.0]
  def change
    create_table :file_uploads do |t|
      t.string :var, null: false, default: ""
      t.timestamps
    end
  end
end
