class CreateServiceMeta < ActiveRecord::Migration[6.0]
  def change
    create_table :service_meta do |t|
      t.references :service, null: false, foreign_key: true
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
