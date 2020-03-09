class CreateServices < ActiveRecord::Migration[6.0]
  def change
    create_table :services do |t|
      t.belongs_to :organisation
      t.string :name
      t.text :description
      t.string :email
      t.string :url
      t.timestamps
    end
  end
end
