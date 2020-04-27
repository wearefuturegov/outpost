class CreateEdits < ActiveRecord::Migration[6.0]
  def change
    create_table :edits do |t|
      t.json :object
      t.string :action
      t.references :user, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true

      t.timestamps
    end
  end
end
