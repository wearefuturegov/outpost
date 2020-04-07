class CreateTaxonomies < ActiveRecord::Migration[6.0]
  def change
    create_table :taxonomies do |t|
      t.string :name

      t.timestamps
    end

    create_table :service_taxonomies do |t|
      t.belongs_to :taxonomy
      t.belongs_to :service
      t.timestamps
    end

  end
end
