class CreateLocalOffers < ActiveRecord::Migration[6.0]
  def change
    create_table :local_offers do |t|
      t.text :description
      t.references :service, null: false, foreign_key: true
      t.string :link

      t.timestamps
    end
  end
end
