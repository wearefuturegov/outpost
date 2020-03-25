class CreatePhones < ActiveRecord::Migration[6.0]
  def change
    create_table :phones do |t|
      t.belongs_to :contact
      t.string :number
    end
  end
end
